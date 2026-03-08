//
//  AlbumDetailStore.swift
//  SongDrop
//
//  Created by Rohan Sastri on 3/7/26.
//

import Foundation

@MainActor
@Observable
final class AlbumDetailStore: DetailStorable {

    let networkCache: NetworkCache<SearchResponse>
    let endpoint: String
    let item: Album
    let defaultProvider: Provider
    var type: ResourceType { item.type }
    var searchTerm: String {
        "\(item.name) \(item.artist)"
    }

    public var isSearching: Bool = false
    public var shareUrls: [Provider: URL] = [:]
    public var detailError: DetailError? = nil

    init(
        networkCache: NetworkCache<SearchResponse>,
        apiConfig: APIConfig,
        item: Album,
        provider: Provider
    ) {
        self.networkCache = networkCache
        self.item = item
        self.endpoint = apiConfig.search.absoluteString
        self.defaultProvider = provider

        // TODO: Dynamic provider
        self.shareUrls[self.defaultProvider] = item.shareUrl
    }

    func search() async {
        await performSequentialSearch()
    }
}

