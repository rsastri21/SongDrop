//
//  SearchView.swift
//  SongDrop
//
//  Created by Rohan Sastri on 3/7/26.
//

import SwiftUI

struct SearchView: View {

    @Environment(SearchStore.self) var searchStore

    var body: some View {
        @Bindable var bindableSearchStore = searchStore

        NavigationStack {
            Group {
                if searchStore.isEmpty {
                    ContentUnavailableView.search
                } else if searchStore.isLoading {
                    ProgressView {
                        Text("Loading...")
                    }
                } else {
                    List {
                        Section(header: Text("Tracks")) {
                            ForEach(searchStore.tracks) { track in
                                SearchItemResultView(
                                    item: track,
                                    title: track.name,
                                    subtitle: track.artists.joined(
                                        separator: ", "
                                    ),
                                    thumbnail: track.thumbnail,
                                    shape: .square
                                )
                            }
                        }
                        Section(header: Text("Artists")) {
                            ForEach(searchStore.artists) { artist in
                                SearchItemResultView(
                                    item: artist,
                                    title: artist.name,
                                    subtitle: nil,
                                    thumbnail: artist.thumbnail,
                                    shape: .circle
                                )
                            }
                        }
                        Section(header: Text("Albums")) {
                            ForEach(searchStore.albums) { album in
                                SearchItemResultView(
                                    item: album,
                                    title: album.name,
                                    subtitle: album.artist,
                                    thumbnail: album.thumbnail,
                                    shape: .square
                                )
                            }
                        }
                    }
                    .listStyle(.inset)
                }
            }
            .navigationTitle(Text("Search"))
            .navigationDestination(for: Track.self) { track in
                TrackDetailView(track: track)
            }
            .searchable(text: $bindableSearchStore.query)
        }
    }
}

#Preview {
    SearchView()
        .environment(SearchStore(networkCache: .init(), apiConfig: APIConfig()))
        .environment(ImageStore())
}
