//
//  RecentItemView.swift
//  SongDrop
//
//  Created by Rohan Sastri on 3/24/26.
//

import SwiftUI

struct RecentItemView<T: Displayable>: View {

    let item: T

    var body: some View {
        VStack(alignment: .leading) {
            CachedAsyncImage(url: item.art) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .frame(width: 156, height: 156)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                case .failure:
                    Image(systemName: "exclamationmark.triangle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 48, height: 48)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                case .empty:
                    ProgressView()
                }
            }
            Text(item.name)
                .fontWeight(.medium)
                .font(.footnote)
        }
        .frame(width: 160, height: 160)
    }
}

#Preview {
    RecentItemView(
        item: Track(
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
    )
    .environment(ImageStore())
}
