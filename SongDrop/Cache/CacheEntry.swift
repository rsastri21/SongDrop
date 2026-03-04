//
//  CacheEntry.swift
//  SongDrop
//
//  Created by Rohan Sastri on 3/3/26.
//

import Foundation

nonisolated final class CacheEntry<V: Codable> {
    
    let key: String
    let value: V
    let expiredTimestamp: Date?
    
    init(key: String, value: V, expiredTimestamp: Date? = nil) {
        self.key = key
        self.value = value
        self.expiredTimestamp = expiredTimestamp
    }
    
    func isExpired(date: Date = .now) -> Bool {
        guard let expiredTimestamp else { return false }
        return date > expiredTimestamp
    }
}

extension CacheEntry: Codable where V: Codable {}
