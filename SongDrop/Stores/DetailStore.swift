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

protocol DetailStorable<V>: AnyObject {
    
    associatedtype V
    var networkCache: NetworkCache<SearchResponse> { get }
    var endpoint: String { get }
    var isSearching: Bool { get set }
    var shareUrls: ShareUrl? { get set }
    var detailError: DetailError? { get set }
    var provider: Provider { get }

    func search(for item: V) async
}

@MainActor
extension DetailStorable {

    func performSearch(term: String, type: ResourceType) async {
        detailError = nil
        isSearching = true
        defer { isSearching = false }

        do {
            guard
                let request = self.buildRequest(
                    for: .resolve(
                        ResolveRequest(
                            mode: .resolve,
                            provider: provider,
                            type: type,
                            query: term
                        )
                    )
                )
            else { return }

            let resp = try await networkCache.get(from: request)
            guard let response = resp else { return }

            guard let shareUrl = self.handleResponse(for: response) else {
                return
            }
            shareUrls = shareUrl
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

    func handleResponse(for response: SearchResponse) -> ShareUrl? {
        switch response {
        case .resolve(let resolve):
            switch resolve.item {
            case .album(let album):
                return album.shareUrl
            case .artist(let artist):
                return artist.shareUrl
            case .track(let track):
                return track.shareUrl
            }
        case .typeahead(_):
            // no-op, handled by SearchStore
            return nil
        }
    }
}
