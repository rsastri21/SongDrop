//
//  MockCache.swift
//  SongDropTests
//
//  Created by Rohan Sastri on 3/7/26.
//

import Foundation
import Testing

@testable import SongDrop

actor MockCache<V: Codable>: Caching {
    let ttl: TimeInterval

    private var storage: [String: CacheEntry<V>] = [:]
    private(set) var getCalls: [String] = []
    private(set) var setCalls: [(key: String, value: V?)] = []
    private(set) var removeCalls: [String] = []
    private(set) var removeAllCallCount: Int = 0
    private(set) var loadFromDiskCallCount: Int = 0

    init(ttl: TimeInterval = 60 * 60) {
        self.ttl = ttl
    }

    func get(forKey key: String) -> V? {
        getCalls.append(key)
        guard let entry = storage[key] else {
            return nil
        }
        if entry.isExpired() {
            storage[key] = nil
            return nil
        }
        return entry.value
    }

    func getRecent(count: Int) -> [V] {
        let keys = Array(storage.keys).sorted()
        let start = max(0, keys.count - count)
        return keys[start..<keys.count].compactMap { key in
            storage[key]?.value
        }
    }

    func set(_ value: V?, forKey key: String) {
        setCalls.append((key, value))
        guard let value else {
            storage[key] = nil
            return
        }
        let entry = CacheEntry(key: key, value: value, expiredTimestamp: Date().addingTimeInterval(ttl))
        storage[key] = entry
    }

    func remove(forKey key: String) {
        removeCalls.append(key)
        storage[key] = nil
    }

    func removeAll() {
        removeAllCallCount += 1
        storage.removeAll()
    }

    func loadFromDisk() throws {
        loadFromDiskCallCount += 1
    }

}
