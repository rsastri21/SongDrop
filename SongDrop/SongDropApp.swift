//
//  SongDropApp.swift
//  SongDrop
//
//  Created by Rohan Sastri on 3/2/26.
//

import SwiftUI

@main
struct SongDropApp: App {

    /// Image Dependencies
    @State var imageStore: ImageStore

    /// Network Dependencies
    @State var apiConfig: APIConfig
    @State var searchCache: NetworkCache<SearchResponse>
    @State var searchStore: SearchStore

    init() {
        let apiConfig = APIConfig()
        let searchCache = NetworkCache<SearchResponse>(
            cache: Cache(filename: "searchcache")
        )
        let imageStore = ImageStore.shared
        let searchStore = SearchStore(
            networkCache: searchCache,
            apiConfig: apiConfig
        )
        
        Task {
            await searchCache.hydrate()
            try? await ImageCache.shared.hydrate()
        }
        
        _apiConfig = State(initialValue: apiConfig)
        _searchCache = State(initialValue: searchCache)
        _imageStore = State(initialValue: imageStore)
        _searchStore = State(initialValue: searchStore)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(imageStore)
                .environment(searchStore)
        }
    }
}
