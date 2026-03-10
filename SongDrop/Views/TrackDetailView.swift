//
//  TrackDetailView.swift
//  SongDrop
//
//  Created by Rohan Sastri on 3/9/26.
//

import SwiftUI

struct TrackDetailView: View {

    @Environment(ImageStore.self) private var imageStore
    @Environment(TrackDetailStore.self) private var trackStore

    let track: Track

    @State private var colors: GradientColors? = nil

    private var imageState: ImageStore.State {
        imageStore.state(for: track.thumbnail.absoluteString)
    }

    var body: some View {
        VStack {
            GlassEffectContainer {
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
                                .foregroundStyle(.primary)
                            Spacer()
                        }
                        HStack {
                            Text(track.artists.joined(separator: ", "))
                                .font(.title2)
                                .fontWeight(.medium)
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                    }
                }
                .padding()
            }
            .glassEffect(in: .rect(cornerRadius: 24, style: .continuous))
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
            imageStore.load(url: track.thumbnail)
            await trackStore.search()
        }
        .onChange(of: imageState) {
            if case .loaded(let uIImage) = imageState {
                colors = GradientExtractor.fitGradient(from: uIImage)
            }
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
            shareUrl: URL(
                string: "https://open.spotify.com/track/0tgVpDi06FyKpA1z0VMD4v"
            )!,
            type: .track
        )
    )
    .environment(ImageStore.shared)
    .environment(
        TrackDetailStore(
            networkCache: .init(),
            apiConfig: APIConfig(),
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
                shareUrl: URL(
                    string:
                        "https://open.spotify.com/track/0tgVpDi06FyKpA1z0VMD4v"
                )!,
                type: .track
            ),
            provider: .spotify
        )
    )
}
