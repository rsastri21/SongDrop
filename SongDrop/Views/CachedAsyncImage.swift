//
//  CachedAsyncImage.swift
//  SongDrop
//
//  Created by Rohan Sastri on 3/6/26.
//

import Foundation
import SwiftUI

enum CachedAsyncImagePhase {
    case empty
    case success(Image)
    case failure(Error)
}

struct CachedAsyncImage<Content: View>: View {

    @State private var phase: CachedAsyncImagePhase = .empty

    private let url: URL
    private let content: (CachedAsyncImagePhase) -> Content

    init(
        url: URL,
        @ViewBuilder content: @escaping (CachedAsyncImagePhase) -> Content,
    ) {
        self.url = url
        self.content = content
    }

    var body: some View {
        content(phase)
            .task {
                do {
                    let image = try await ImageCache.shared.image(forUrl: url)
                    phase = .success(Image(uiImage: image))
                } catch {
                    phase = .failure(error)
                }
            }
    }
}
