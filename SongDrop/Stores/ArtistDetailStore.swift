//
//  ArtistDetailStore.swift
//  SongDrop
//
//  Created by Rohan Sastri on 3/7/26.
//

import Foundation

@MainActor
@Observable
final class ArtistDetailStore: DetailStorable {
    
    let networkCache: NetworkCache<SearchResponse>
    let endpoint: String
    let defaultProvider: Provider
    
    public var isSearching: Bool = false
    public var shareUrls: ShareUrl? = nil
    public var detailError: DetailError? = nil
    // TODO: Get provider dynamically
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
    
    func search(for item: Artist) async {
        var searchTerm: String { item.name }
        await performSearch(term: searchTerm, type: item.type)
    }
}
