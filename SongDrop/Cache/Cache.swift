//
//  Cache.swift
//  SongDrop
//
//  Created by Rohan Sastri on 3/3/26.
//

import Foundation
import OrderedCollections

protocol Caching: Actor {
    
    associatedtype V
    var ttl: TimeInterval { get }
    
    func get(forKey key: String) -> V?
    func getRecent(count: Int) -> [V]
    func set(_ value: V?, forKey key: String)
    func remove(forKey key: String)
    func removeAll()
    func loadFromDisk() throws
}

actor Cache<V: Codable>: Caching {
    
    // MARK: - Properties
    
    private let cache: NSCache<NSString, CacheEntry<V>>
    private var keyTracker: KeyTracker<V>
    
    private let filename: String
    private var saveLocationUrl: URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("\(filename).cache")
    }
    var ttl: TimeInterval
    
    // MARK: - Initialization
    
    init(cache: NSCache<NSString, CacheEntry<V>> = .init(),
         keyTracker: KeyTracker<V> = .init(),
         filename: String,
         ttl: TimeInterval = 60 * 60 * 24 * 30) {
        self.cache = cache
        self.keyTracker = keyTracker
        self.filename = filename
        self.ttl = ttl
    }
    
    // MARK: - Public API
    
    func get(forKey key: String) -> V? {
        entry(forKey: key)?.value
    }
    
    func getRecent(count: Int = 10) -> [V] {
        let start = max(0, keyTracker.keys.count - count)
        let keySet = Array(keyTracker.keys[start..<keyTracker.keys.count])
        return keySet.compactMap { key in
            get(forKey: key)
        }
    }
    
    func set(_ value: V?, forKey key: String) {
        if let value = value {
            let expiredTimestamp = Date().addingTimeInterval(ttl)
            let cacheEntry = CacheEntry(key: key, value: value, expiredTimestamp: expiredTimestamp)
            insert(cacheEntry)
        } else {
            remove(forKey: key)
        }
        
        // Save to disk, error can be re-tried on next write
        try? saveToDisk()
    }
    
    func remove(forKey key: String) {
        keyTracker.keys.remove(key)
        cache.removeObject(forKey: key as NSString)
        
        try? saveToDisk()
    }
    
    func removeAll() {
        keyTracker.keys.removeAll()
        cache.removeAllObjects()
        
        try? saveToDisk()
    }
    
    func loadFromDisk() throws {
        let data = try Data(contentsOf: saveLocationUrl)
        let entries = try JSONDecoder().decode(Array<CacheEntry<V>>.self, from: data)
        entries.forEach { insert($0) }
    }

    // MARK: - Helper Functions
    
    private func insert(_ entry: CacheEntry<V>) {
        keyTracker.keys.append(entry.key)
        cache.setObject(entry, forKey: entry.key as NSString)
    }
    
    private func entry(forKey key: String) -> CacheEntry<V>? {
        guard let entry = cache.object(forKey: key as NSString) else {
            return nil
        }
        
        guard !entry.isExpired() else {
            remove(forKey: key)
            return nil
        }
        
        return entry
    }
    
    private func saveToDisk() throws {
        let entries = keyTracker.keys.compactMap(entry)
        let data = try JSONEncoder().encode(entries)
        try data.write(to: saveLocationUrl)
    }
    
}
