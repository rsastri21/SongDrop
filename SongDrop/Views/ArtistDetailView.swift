//
//  ArtistDetailView.swift
//  SongDrop
//
//  Created by Rohan Sastri on 5/1/26.
//

import SwiftUI

struct ArtistDetailView: View {

    @Environment(ArtistDetailStore.self) private var artistStore

    let artist: Artist

    @State private var colors: GradientColors? = nil
    private var isDark: Bool { GradientExtractor.isDark(colors: colors) }

    var body: some View {
        VStack(spacing: 32) {
            VStack {
                displayArtwork(url: artist.art)
                Text(artist.name)
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundStyle(isDark ? .white : .black)
                    .lineLimit(1)
            }
            .padding()
            ShareSectionView(store: artistStore)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.easeInOut, value: artistStore.shareUrls != nil)
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
            guard let thumbnail = artist.thumbnail else { return }
            if let image = try? await ImageCache.shared.image(forUrl: thumbnail)
            {
                colors = GradientExtractor.fitGradient(from: image)
            }
            await artistStore.search(for: artist)
        }
    }

    @ViewBuilder
    func displayArtwork(url: URL?) -> some View {
        if let url = url {
            CachedAsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 300)
                        .clipShape(Circle())
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
        } else {
            Image(systemName: "photo.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 64, height: 64)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}

#Preview {
    ArtistDetailView(
        artist: Artist(
            id: "6eUKZXaKkcviH0Ku9w2n3V",
            name: "Ed Sheeran",
            thumbnail: URL(
                string:
                    "https://i.scdn.co/image/ab6761610000f178d55c95ad400aed87da52daec"
            )!,
            art: URL(
                string:
                    "https://i.scdn.co/image/ab6761610000e5ebd55c95ad400aed87da52daec"
            )!,
            shareUrl:
                ShareUrl(
                    spotify: URL(
                        string:
                            "https://open.spotify.com/artist/6eUKZXaKkcviH0Ku9w2n3V"
                    )!,
                    appleMusic: URL(
                        string:
                            "https://music.apple.com/us/artist/ed-sheeran/183313439"
                    )!
                ),
            type: .artist
        )
    )
    .environment(
        ArtistDetailStore(
            networkCache: .init(),
            apiConfig: .init(),
            providerStore: .init(apiConfig: .init())
        )
    )
}
