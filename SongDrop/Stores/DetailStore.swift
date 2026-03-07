//
//  DetailStore.swift
//  SongDrop
//
//  Created by Rohan Sastri on 3/6/26.
//

import Foundation

enum DetailError: Error {
    case failed(Error)
}

protocol DetailStorable: AnyObject {
    var networkCache: NetworkCache<SearchResponse> { get }
    var endpoint: String { get }
    var type: ResourceType { get }
    var searchTerm: String { get }
    var defaultProvider: Provider { get }
    var isSearching: Bool { get set }
    var shareUrls: [Provider: URL] { get set }
    var detailError: DetailError? { get set }

    func search() async
}

@MainActor
extension DetailStorable {
    
    func performSequentialSearch() async {
        detailError = nil
        isSearching = true
        defer { isSearching = false }
        let providersToSearch = Provider.allCases.filter {
            defaultProvider != $0
        }

        do {
            for provider in providersToSearch {
                guard
                    let request = self.buildRequest(
                        for: .resolve(
                            ResolveRequest(
                                mode: .resolve,
                                provider: provider,
                                type: type,
                                query: searchTerm
                            )
                        )
                    )
                else { return }
                
                let resp = try await networkCache.get(from: request)
                guard let response = resp else { return }
                
                guard let (from, url) = self.handleResponse(for: response) else { return }
                self.shareUrls[from] = url
            }
        } catch {
            detailError = .failed(error)
        }
    }

    func buildRequest(for request: SearchRequest) -> URLRequest? {
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

    func handleResponse(for response: SearchResponse) -> (Provider, URL)? {
        switch response {
        case .resolve(let resolve):
            let from = resolve.from
            let shareUrl: URL
            switch resolve.item {
            case .album(let album):
                shareUrl = album.shareUrl
            case .artist(let artist):
                shareUrl = artist.shareUrl
            case .track(let track):
                shareUrl = track.shareUrl
            }
            return (from, shareUrl)
        case .typeahead(_):
            // no-op, handled by SearchStore
            return nil
        }
    }
}
