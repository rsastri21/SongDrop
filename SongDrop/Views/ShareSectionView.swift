//
//  ShareSectionView.swift
//  SongDrop
//
//  Created by Rohan Sastri on 5/1/26.
//

import SwiftUI

struct ShareSectionView: View {

    let store: any DetailStorable

    var body: some View {
        VStack(spacing: 16) {
            if let spotifyUrl = store.shareUrls?.spotify {
                SharePillView(
                    title: "Share from Spotify",
                    icon: .spotifyLogoGreen,
                    url: spotifyUrl
                )
                .transition(.scale(scale: 0.9).combined(with: .opacity))
            }
            if let appleMusicUrl = store.shareUrls?.appleMusic {
                SharePillView(
                    title: "Share from Apple Music",
                    icon: .appleMusicIconRGBSm073120,
                    url: appleMusicUrl
                )
                .transition(.scale(scale: 0.9).combined(with: .opacity))
            }
        }
    }
}

#Preview {
    ShareSectionView(
        store: AlbumDetailStore(
            networkCache: .init(),
            apiConfig: .init(),
            providerStore: .init(apiConfig: .init())
        )
    )
}
