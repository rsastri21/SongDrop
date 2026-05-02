//
//  ImageCache.swift
//  SongDrop
//
//  Created by Rohan Sastri on 3/5/26.
//

import Foundation
import CryptoKit
import UIKit

enum FetchState {
    case fetching(Task<URL, Error>)
    case cached(URL)
}

// MARK: - ImageCache

actor ImageCache {
    
    private let fileManager: FileManager
    private let urlSession: URLSessionProtocol
    private let cacheDirectory: URL
    private let metadataCache: NSCache<NSString, CacheEntry<FetchState>>
    
    public static let shared = ImageCache()
    
    init(fileManager: FileManager = .default, urlSession: URLSessionProtocol = URLSession.shared, metadataCache: NSCache<NSString, CacheEntry<FetchState>> = .init()) {
        self.fileManager = fileManager
        self.urlSession = urlSession
        self.cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent("imagecache", isDirectory: true)
        self.metadataCache = metadataCache
        
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    func hydrate() throws {
        try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil).forEach { fileUrl in
            let key = fileUrl.deletingPathExtension().lastPathComponent
            let entry: CacheEntry<FetchState> = CacheEntry(key: key, value: .cached(fileUrl))
            
            metadataCache.setObject(entry, forKey: key as NSString)
        }
    }
    
    func clearAll() throws {
        metadataCache.removeAllObjects()
        let files = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil)
        for file in files {
            try fileManager.removeItem(at: file)
        }
    }
    
    func get(for remoteUrl: URL) async throws -> URL {
        let key = sha256(remoteUrl.absoluteString)
        let fileUrl = diskUrl(for: remoteUrl)
        
        // Case 1: Check metadata cache
        if let entry = metadataCache.object(forKey: key as NSString) {
            let state = entry.value
            switch state {
            case .cached(let url):
                return url
            case .fetching(let task):
                return try await task.value
            }
        }
        
        // Disk backup if memory cache is not hydrated
        if fileManager.fileExists(atPath: fileUrl.path) {
            let entry: CacheEntry<FetchState> = CacheEntry(key: key, value: .cached(fileUrl))
            metadataCache.setObject(entry, forKey: key as NSString)
            
            return fileUrl
        }
        
        // Case 2: Cache miss -> Start download
        let task = createDownloadTask(for: remoteUrl)
        let entry: CacheEntry<FetchState> = CacheEntry(key: key, value: .fetching(task))
        metadataCache.setObject(entry, forKey: key as NSString)
        
        do {
            let url = try await task.value
            
            let entry: CacheEntry<FetchState> = CacheEntry(key: key, value: .cached(url))
            metadataCache.setObject(entry, forKey: key as NSString)
            
            return url
        } catch {
            metadataCache.removeObject(forKey: key as NSString)
            throw error
        }
    }
    
    private func createDownloadTask(for url: URL) -> Task<URL, Error> {
        return Task<URL, Error> {
            let destination = diskUrl(for: url)
            let (tempUrl, _) = try await urlSession.download(from: url, delegate: nil)
            try fileManager.moveItem(at: tempUrl, to: destination)
            return destination
        }
    }
}

// MARK: - UIImage Extension

extension ImageCache {
    func image(forUrl url: URL) async throws -> UIImage {
        let fileUrl = try await get(for: url)
        guard let image = UIImage(contentsOfFile: fileUrl.path) else {
            throw URLError(.cannotDecodeContentData)
        }
        return image
    }
}

// MARK: - File Utilities

private extension ImageCache {
    
    func diskUrl(for remoteUrl: URL) -> URL {
        let filename = sha256(remoteUrl.absoluteString)
        return cacheDirectory.appendingPathComponent(filename)
    }
    
    func sha256(_ input: String) -> String {
        let data = Data(input.utf8)
        let hash = SHA256.hash(data: data)
        return hash.map { String(format: "%02x", $0) }.joined()
    }
}
