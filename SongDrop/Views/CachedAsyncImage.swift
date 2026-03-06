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
    
    @Environment(ImageStore.self) private var store
    
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
        switch store.state(for: url.absoluteString) {
        case .idle:
            content(.empty)
                .task {
                    store.load(url: url)
                }
        case .loading:
            content(.empty)
        case .loaded(let image):
            content(.success(Image(uiImage: image)))
        case .failed(let error):
            content(.failure(error))
        }
    }
}
