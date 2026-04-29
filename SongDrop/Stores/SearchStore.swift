//
//  SearchStore.swift
//  SongDrop
//
//  Created by Rohan Sastri on 3/6/26.
//

import Combine
import Foundation

enum SearchError: Error {
    case failed(Error)
}

@MainActor
protocol SearchStorable: Observable {
    var query: String { get set }
    var provider: Provider { get }

    var tracks: [Track] { get set }
    var artists: [Artist] { get set }
    var albums: [Album] { get set }

    var isEmpty: Bool { get }
    var isLoading: Bool { get set }
    var searchError: SearchError? { get set }
}

@MainActor
@Observable
final class SearchStore: SearchStorable {

    private let networkCache: NetworkCache<SearchResponse>
    private let endpoint: String

    @ObservationIgnored private var queryTextSubject = CurrentValueSubject<
        String, Never
    >("")
    @ObservationIgnored private var cancellables = Set<AnyCancellable>()

    // MARK: - State

    var searchTask: Task<Void, Never>?
    public var query: String = "" {
        didSet {
            queryTextSubject.send(query)
        }
    }
    private let providerStore: ProviderStore
    public var provider: Provider { providerStore.selectedProvider }

    public var tracks: [Track] = []
    public var artists: [Artist] = []
    public var albums: [Album] = []
    public var recents: [ResolveItem] = []

    public var isEmpty: Bool {
        tracks.isEmpty && artists.isEmpty && albums.isEmpty
    }
    public var isLoading: Bool = false
    public var searchError: SearchError? = nil

    init(
        networkCache: NetworkCache<SearchResponse>,
        apiConfig: APIConfig,
        providerStore: ProviderStore
    ) {
        self.networkCache = networkCache
        self.endpoint = apiConfig.search.absoluteString
        self.providerStore = providerStore

        queryTextSubject
            .filter { $0.isEmpty }
            .debounce(for: .milliseconds(50), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self, self.query.isEmpty else { return }
                self.searchTask?.cancel()
                self.displayEmptyState()
            }
            .store(in: &cancellables)

        queryTextSubject
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .filter {
                !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            }
            .sink { [weak self] text in
                guard let self else { return }
                self.searchTask?.cancel()
                self.searchTask = self.search(text)
            }
            .store(in: &cancellables)
    }

    func search(_ text: String) -> Task<Void, Never> {
        Task { @MainActor [weak self] in
            guard let self else { return }
            self.searchError = nil
            self.isLoading = true
            defer { isLoading = false }

            do {
                guard
                    let request = buildRequest(
                        for: .typeahead(
                            TypeaheadRequest(
                                mode: .typeahead,
                                provider: provider,
                                query: text
                            )
                        )
                    )
                else { return }

                let resp = try await networkCache.get(from: request)
                guard let response = resp else { return }

                try Task.checkCancellation()
                self.handleResponse(for: response)
            } catch {
                if !(error is CancellationError) {
                    self.searchError = .failed(error)
                }
            }
        }
    }

    func getRecents() async {
        let cachedSearches = await networkCache.getRecent(count: 32)
        let resolveSearches = Array(
            cachedSearches
                .lazy
                .compactMap {
                    if case .resolve(let value) = $0 { return value }
                    return nil
                }
                .prefix(16)
        )
        recents = resolveSearches.map { $0.item }
    }

    private func buildRequest(for request: SearchRequest) -> URLRequest? {
        guard let baseUrl = URL(string: endpoint) else {
            return nil
        }
        var components = URLComponents(
            url: baseUrl,
            resolvingAgainstBaseURL: false
        )
        components?.queryItems = request.queryItems

        guard let url = components?.url else {
            return nil
        }
        return URLRequest(url: url)
    }

    private func handleResponse(for response: SearchResponse) {
        switch response {
        case .typeahead(let typeahead):
            tracks = typeahead.tracks
            artists = typeahead.artists
            albums = typeahead.albums
        case .resolve(_):
            // no-op, handled by DetailStore
            return
        }
    }

    private func displayEmptyState() {
        tracks = []
        artists = []
        albums = []
    }
}
