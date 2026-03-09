//
//  SearchItemResultView.swift
//  SongDrop
//
//  Created by Rohan Sastri on 3/8/26.
//

import SwiftUI

enum ThumbnailShape {
    case square
    case circle
}

struct SearchItemResultView<T: Hashable>: View {

    let item: T
    let title: String
    let subtitle: String?
    let thumbnail: URL?
    let shape: ThumbnailShape

    private var radius: CGFloat {
        shape == .square ? 4 : .infinity
    }

    var body: some View {
        NavigationLink(value: item) {
            HStack {
                if let imageUrl = thumbnail {
                    CachedAsyncImage(url: imageUrl) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .frame(width: 48, height: 48)
                                .clipShape(RoundedRectangle(cornerRadius: radius))
                        case .failure:
                            Image(systemName: "exclamationmark.triangle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 48, height: 48)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        case .empty:
                            ProgressView()
                        }
                    }
                } else {
                    Image(systemName: "photo.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 48, height: 48)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
                VStack(alignment: .leading) {
                    Text(title)
                        .fontWeight(.medium)
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
            }
        }
    }
}

#Preview {
    SearchItemResultView(
        item: "test",
        title: "Perfect",
        subtitle: "Ed Sheeran",
        thumbnail: URL(
            string:
                "https://i.scdn.co/image/ab67616d00004851ba5db46f4b838ef6027e6f96"
        ),
        shape: .square
    )
    .environment(ImageStore())
}
