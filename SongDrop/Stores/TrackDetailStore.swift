//
//  TrackDetailStore.swift
//  SongDrop
//
//  Created by Rohan Sastri on 3/7/26.
//

import Foundation

@MainActor
@Observable
final class TrackDetailStore: DetailStorable {

    let networkCache: NetworkCache<SearchResponse>
    let endpoint: String
    let defaultProvider: Provider

    public var isSearching: Bool = false
    public var shareUrls: ShareUrl? = nil
    public var detailError: DetailError? = nil
    // TODO: Get from a ProviderStore
    public let provider: Provider = .spotify

    init(
        networkCache: NetworkCache<SearchResponse>,
        apiConfig: APIConfig,
        provider: Provider
    ) {
        self.networkCache = networkCache
        self.endpoint = apiConfig.search.absoluteString
        self.defaultProvider = provider
    }

    func search(for item: Track) async {
        var searchTerm: String {
            "\(item.name) \(item.album) \(item.artists.joined(separator: ", "))"
        }
        await performSearch(term: searchTerm, type: item.type)
    }
}
