//
//  RecentsView.swift
//  SongDrop
//
//  Created by Rohan Sastri on 3/24/26.
//

import SwiftUI

struct RecentsView: View {

    @Environment(SearchStore.self) var searchStore

    private var tracks: [Track] {
        var seen = Set<String>()
        return searchStore.recents.compactMap { item in
            switch item {
            case .track(let track):
                let key = track.name.lowercased() + (track.artists.first?.lowercased() ?? "")
                return seen.insert(key).inserted ? track : nil
            default:
                return nil
            }
        }
    }

    private var albums: [Album] {
        var seen = Set<String>()
        return searchStore.recents.compactMap { item in
            switch item {
            case .album(let album):
                let key = album.name.lowercased() + album.artist.lowercased()
                return seen.insert(key).inserted ? album : nil
            default:
                return nil
            }
        }
    }

    private var artists: [Artist] {
        searchStore.recents.compactMap { item in
            switch item {
            case .artist(let artist):
                return artist
            default:
                return nil
            }
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView(.vertical) {
                RecentItemListView(
                    title: "Tracks",
                    items: tracks,
                    icon: "music.note"
                )
                RecentItemListView(
                    title: "Albums",
                    items: albums,
                    icon: "music.note.list"
                )
                Spacer()
            }
            .navigationTitle("Recents")
            .navigationDestination(for: Track.self) { track in
                TrackDetailView(track: track)
            }
            .navigationDestination(for: Album.self) { album in
                AlbumDetailView(album: album)
            }
        }
        .task {
            await searchStore.getRecents()
        }
    }
}

#Preview {
    RecentsView()
        .environment(
            SearchStore(
                networkCache: .init(),
                apiConfig: .init(),
                providerStore: .init(apiConfig: APIConfig())
            )
        )
}
