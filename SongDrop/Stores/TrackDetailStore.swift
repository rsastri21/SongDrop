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
    let endpoint = "http://localhost:3000/v1/search"
    let item: Track
    let defaultProvider: Provider
    var type: ResourceType { item.type }
    var searchTerm: String {
        "\(item.name) \(item.album) \(item.artists.joined(separator: ", "))"
    }

    public var isSearching: Bool = false
    public var shareUrls: [Provider: URL] = [:]
    public var detailError: DetailError? = nil

    init(
        networkCache: NetworkCache<SearchResponse>,
        item: Track,
        provider: Provider
    ) {
        self.networkCache = networkCache
        self.item = item
        self.defaultProvider = provider

        // TODO: Dynamic provider
        self.shareUrls[self.defaultProvider] = item.shareUrl
    }

    func search() async {
        await performSequentialSearch()
    }
}
