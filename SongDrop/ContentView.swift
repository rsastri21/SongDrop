//
//  ContentView.swift
//  SongDrop
//
//  Created by Rohan Sastri on 3/2/26.
//

import SwiftUI

struct ContentView: View {

    var body: some View {
        TabView {
            Tab("Recents", systemImage: "music.note") {
                RecentsView()
            }
            Tab("Settings", systemImage: "gear") {
                SettingsView()
            }
            Tab("Search", systemImage: "magnifyingglass", role: .search) {
                SearchView()
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(
            SearchStore(
                networkCache: .init(),
                apiConfig: APIConfig(),
                providerStore: .init(apiConfig: APIConfig())
            )
        )
        .environment(
            TrackDetailStore(
                networkCache: .init(),
                apiConfig: APIConfig(),
                providerStore: .init(apiConfig: APIConfig())
            )
        )
        .environment(
            AlbumDetailStore(
                networkCache: .init(),
                apiConfig: APIConfig(),
                providerStore: .init(apiConfig: APIConfig())
            )
        )
        .environment(ProviderStore(apiConfig: .init()))
        .environment(CacheCoordinator(searchCache: .init()))
}
