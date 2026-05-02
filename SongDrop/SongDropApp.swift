//
//  SongDropApp.swift
//  SongDrop
//
//  Created by Rohan Sastri on 3/2/26.
//

import SwiftUI

@main
struct SongDropApp: App {

    /// Network Dependencies
    @State var apiConfig: APIConfig
    @State var providerStore: ProviderStore
    @State var searchCache: NetworkCache<SearchResponse>
    @State var cacheCoordinator: CacheCoordinator
    @State var searchStore: SearchStore
    @State var trackDetailStore: TrackDetailStore
    @State var albumDetailStore: AlbumDetailStore
    @State var artistDetailStore: ArtistDetailStore

    init() {
        let apiConfig = APIConfig()
        let providerStore = ProviderStore(apiConfig: apiConfig)
        let searchCache = NetworkCache<SearchResponse>(
            cache: Cache(filename: "searchcache")
        )
        let cacheCoordinator = CacheCoordinator(searchCache: searchCache)
        let searchStore = SearchStore(
            networkCache: searchCache,
            apiConfig: apiConfig,
            providerStore: providerStore
        )
        let trackDetailStore = TrackDetailStore(
            networkCache: searchCache,
            apiConfig: apiConfig,
            providerStore: providerStore
        )
        let albumDetailStore = AlbumDetailStore(
            networkCache: searchCache,
            apiConfig: apiConfig,
            providerStore: providerStore
        )
        let artistDetailStore = ArtistDetailStore(
            networkCache: searchCache,
            apiConfig: apiConfig,
            providerStore: providerStore
        )

        Task {
            await providerStore.loadProviders()
            await searchCache.hydrate()
            try? await ImageCache.shared.hydrate()
        }

        _apiConfig = State(initialValue: apiConfig)
        _providerStore = State(initialValue: providerStore)
        _searchCache = State(initialValue: searchCache)
        _cacheCoordinator = State(initialValue: cacheCoordinator)
        _searchStore = State(initialValue: searchStore)
        _trackDetailStore = State(initialValue: trackDetailStore)
        _albumDetailStore = State(initialValue: albumDetailStore)
        _artistDetailStore = State(initialValue: artistDetailStore)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(providerStore)
                .environment(cacheCoordinator)
                .environment(searchStore)
                .environment(trackDetailStore)
                .environment(albumDetailStore)
                .environment(artistDetailStore)
        }
    }
}
