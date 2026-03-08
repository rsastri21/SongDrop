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
    let item: Artist
    let defaultProvider: Provider
    var type: ResourceType { item.type }
    var searchTerm: String { item.name }
    
    public var isSearching: Bool = false
    public var shareUrls: [Provider: URL] = [:]
    public var detailError: DetailError? = nil
    
    init(
        networkCache: NetworkCache<SearchResponse>,
        apiConfig: APIConfig,
        item: Artist,
        provider: Provider
    ) {
        self.networkCache = networkCache
        self.endpoint = apiConfig.search.absoluteString
        self.item = item
        self.defaultProvider = provider
        
        // TODO: Dynamic provider
        self.shareUrls[self.defaultProvider] = item.shareUrl
    }
    
    func search() async {
        await performSequentialSearch()
    }
}
