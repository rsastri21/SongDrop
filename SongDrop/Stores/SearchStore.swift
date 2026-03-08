//
//  SearchStore.swift
//  SongDrop
//
//  Created by Rohan Sastri on 3/6/26.
//

import Foundation

@MainActor
@Observable
final class SearchStore {

    private let networkCache: NetworkCache<SearchResponse>
    private let endpoint: String

    enum SearchError: Error {
        case failed(Error)
    }

    // MARK: - State

    public var query: String = ""
    // TODO: Get from a ProviderStore
    public var provider: Provider = .spotify

    public var tracks: [Track] = []
    public var artists: [Artist] = []
    public var albums: [Album] = []

    public var isEmpty: Bool {
        tracks.isEmpty && artists.isEmpty && albums.isEmpty
    }
    public var isLoading: Bool = false
    public var searchError: SearchError? = nil

    init(networkCache: NetworkCache<SearchResponse>, apiConfig: APIConfig) {
        self.networkCache = networkCache
        self.endpoint = apiConfig.search.absoluteString
    }

    func search() async {
        searchError = nil
        
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            tracks = []
            artists = []
            albums = []
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        do {
            guard
                let request = buildRequest(
                    for: .typeahead(
                        TypeaheadRequest(
                            mode: .typeahead,
                            provider: provider,
                            query: query
                        )
                    )
                )
            else { return }
            
            let resp = try await networkCache.get(from: request)
            guard let response = resp else { return }
            
            handleResponse(for: response)
        } catch {
            searchError = .failed(error)
        }
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
}
