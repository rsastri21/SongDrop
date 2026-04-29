//
//  AlbumDetailView.swift
//  SongDrop
//
//  Created by Rohan Sastri on 3/24/26.
//

import SwiftUI

struct AlbumDetailView: View {
    
    @Environment(AlbumDetailStore.self) private var albumStore

    let album: Album

    @State private var colors: GradientColors? = nil
    private var isDark: Bool { GradientExtractor.isDark(colors: colors) }

    var body: some View {
        VStack(spacing: 32) {
            VStack {
                CachedAsyncImage(url: album.art) { phase in
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
                        Text(album.name)
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundStyle(isDark ? .white : .black)
                            .lineLimit(1)
                        Spacer()
                    }
                    HStack {
                        Text(album.artist)
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundStyle(isDark ? .white.opacity(0.5) : .black.opacity(0.5))
                            .lineLimit(2)
                        Spacer()
                    }
                }
            }
            .padding()
            VStack(spacing: 16) {
                if let spotifyUrl = albumStore.shareUrls?.spotify {
                    SharePillView(
                        title: "Share from Spotify",
                        icon: .spotifyLogoGreen,
                        url: spotifyUrl
                    )
                    .transition(.scale(scale: 0.9).combined(with: .opacity))
                }
                if let appleMusicUrl = albumStore.shareUrls?.appleMusic {
                    SharePillView(
                        title: "Share from Apple Music",
                        icon: .appleMusicIconRGBSm073120,
                        url: appleMusicUrl
                    )
                    .transition(.scale(scale: 0.9).combined(with: .opacity))
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.easeInOut, value: albumStore.shareUrls != nil)
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
            if let image = try? await ImageCache.shared.image(forUrl: album.thumbnail) {
                colors = GradientExtractor.fitGradient(from: image)
            }
            await albumStore.search(for: album)
        }
    }
}

#Preview {
    AlbumDetailView(
        album: Album(
            id: "0tgVpDi06FyKpA1z0VMD4v",
            name: "÷ (Deluxe)",
            artist: "Ed Sheeran",
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
            type: .album
        )
    )
    .environment(
        AlbumDetailStore(
            networkCache: .init(),
            apiConfig: APIConfig(),
            providerStore: .init(apiConfig: APIConfig())
        )
    )
}
