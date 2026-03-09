//
//  ImageStore.swift
//  SongDrop
//
//  Created by Rohan Sastri on 3/5/26.
//

import Foundation
import UIKit

@Observable
final class ImageStore {
    
    enum State {
        case idle
        case loading
        case loaded(UIImage)
        case failed(Error)
    }
    
    var states: [String: State] = [:]
    
    private let cache: ImageCache
    
    public static let shared = ImageStore()
    
    init(cache: ImageCache = .shared) {
        self.cache = cache
    }
    
    func state(for key: String) -> State {
        states[key] ?? .idle
    }
    
    func load(url: URL) {
        let key = url.absoluteString
        
        if case .loading = states[key] { return }
        if case .loaded = states[key] { return }
        
        states[key] = .loading
        
        Task {
            do {
                let image = try await cache.image(forUrl: url)
                
                await MainActor.run {
                    states[key] = .loaded(image)
                }
            } catch {
                await MainActor.run {
                    states[key] = .failed(error)
                }
            }
        }
    }
}
