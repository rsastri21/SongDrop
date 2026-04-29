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

    public var isSearching: Bool = false
    public var shareUrls: ShareUrl? = nil
    public var detailError: DetailError? = nil
    // TODO: Get from a ProviderStore
    private let providerStore: ProviderStore
    public var provider: Provider { providerStore.selectedProvider }

    init(
        networkCache: NetworkCache<SearchResponse>,
        apiConfig: APIConfig,
        providerStore: ProviderStore
    ) {
        self.networkCache = networkCache
        self.endpoint = apiConfig.search.absoluteString
        self.providerStore = providerStore
    }

    func search(for item: Track) async {
        var searchTerm: String {
            "\(item.name) \(item.album) \(item.artists.joined(separator: ", "))"
        }
        await performSearch(term: searchTerm, type: item.type)
    }
}
