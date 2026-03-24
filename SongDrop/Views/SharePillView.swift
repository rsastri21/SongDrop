//
//  SharePillView.swift
//  SongDrop
//
//  Created by Rohan Sastri on 3/23/26.
//

import SwiftUI

struct SharePillView: View {

    let title: String
    let icon: ImageResource
    let url: URL

    var body: some View {
        GlassEffectContainer {
            ShareLink(item: url) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.foreground)
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
            }
            .tint(.primary)
            .padding()
            .frame(maxWidth: .infinity)
            .buttonStyle(.plain)
        }
        .glassEffect(in: .rect(cornerRadius: 24, style: .continuous))
        .padding(.horizontal)
    }
}

#Preview {
    SharePillView(
        title: "Share from Spotify",
        icon: .spotifyLogoGreen,
        url: URL(
            string: "https://open.spotify.com/track/0tgVpDi06FyKpA1z0VMD4v"
        )!
    )
}
