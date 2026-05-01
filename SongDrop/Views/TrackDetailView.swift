//
//  TrackDetailView.swift
//  SongDrop
//
//  Created by Rohan Sastri on 3/9/26.
//

import SwiftUI

struct TrackDetailView: View {

    @Environment(TrackDetailStore.self) private var trackStore

    let track: Track

    @State private var colors: GradientColors? = nil
    private var isDark: Bool { GradientExtractor.isDark(colors: colors) }

    var body: some View {
        VStack(spacing: 32) {
            VStack {
                CachedAsyncImage(url: track.art) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .clipShape(
                                ConcentricRectangle(
                                    corners: .concentric(minimum: 16),
                                    isUniform: true
                                )
                            )
                    case .failure:
                        Image(systemName: "exclamationmark.triangle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 64, height: 64)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    case .empty:
                        ProgressView()
                            .scaledToFit()
                    }
                }
                VStack {
                    HStack {
                        Text(track.name)
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundStyle(isDark ? .white : .black)
                            .lineLimit(1)
                        Spacer()
                    }
                    HStack {
                        Text(track.artists.joined(separator: ", "))
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundStyle(isDark ? .white.opacity(0.5) : .black.opacity(0.5))
                            .lineLimit(2)
                        Spacer()
                    }
                }
            }
            .padding()
            ShareSectionView(store: trackStore)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.easeInOut, value: trackStore.shareUrls != nil)
        .background {
            if let colors = colors {
                LinearGradient(
                    colors: [Color(colors.top), Color(colors.bottom)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        }
        .ignoresSafeArea()
        .task {
            if let image = try? await ImageCache.shared.image(forUrl: track.thumbnail) {
                colors = GradientExtractor.fitGradient(from: image)
            }
            await trackStore.search(for: track)
        }
    }
}

#Preview {
    TrackDetailView(
        track: Track(
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
    .environment(
        TrackDetailStore(
            networkCache: .init(),
            apiConfig: APIConfig(),
            providerStore: .init(apiConfig: APIConfig())
        )
    )
}
