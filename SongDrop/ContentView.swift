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
                Text("Recents View")
            }
            Tab("Settings", systemImage: "gear") {
                Text("Settings View")
            }
            Tab("Search", systemImage: "magnifyingglass", role: .search) {
                SearchView()
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(SearchStore(networkCache: .init(), apiConfig: APIConfig()))
        .environment(ImageStore())
}
