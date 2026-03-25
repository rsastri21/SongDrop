//
//  RecentItemListView.swift
//  SongDrop
//
//  Created by Rohan Sastri on 3/24/26.
//

import SwiftUI

struct RecentItemListView<T: Displayable>: View {

    let title: String
    let items: [T]
    let icon: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.title2)
                .fontWeight(.medium)
                .padding(.horizontal)
            if items.isEmpty {
                ContentUnavailableView {
                    Label("No recents", systemImage: icon)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
                .frame(height: 150)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack {
                        ForEach(items, id: \.id) { item in
                            NavigationLink(value: item) {
                                RecentItemView(item: item)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                    .scrollTargetLayout()
                }
                .fixedSize(horizontal: false, vertical: true)
                .scrollTargetBehavior(.viewAligned)
            }
        }
        .padding(.vertical)
    }
}

#Preview {
    RecentItemListView(
        title: "Tracks",
        items: [
            Track(
                id: "0tgVpDi06FyKpA1z0VMD4v",
                name: "Perfect",
                artists: ["Ed Sheeran"],
                album: "÷ (Deluxe)",
                thumbnail: URL(
                    string:
                        "https://i.scdn.co/image/ab67616d00004851ba5db46f4b838ef6027e6f96"
                )!,
                art: URL(
                    string:
                        "https://i.scdn.co/image/ab67616d0000b273ba5db46f4b838ef6027e6f96"
                )!,
                shareUrl:
                    ShareUrl(
                        spotify: URL(
                            string:
                                "https://open.spotify.com/track/0tgVpDi06FyKpA1z0VMD4v"
                        )!,
                        appleMusic: nil
                    ),
                type: .track
            )
        ],
        icon: "music.note",
    )
    .environment(ImageStore())
}
