//
//  KeyTracker.swift
//  SongDrop
//
//  Created by Rohan Sastri on 3/3/26.
//

import Foundation
import OrderedCollections

nonisolated final class KeyTracker<V: Codable>: NSObject, NSCacheDelegate {
    
    var keys = OrderedSet<String>()
    
    func cache(_ cache: NSCache<AnyObject, AnyObject>, willEvictObject obj: Any) {
        guard let entry = obj as? CacheEntry<V> else {
            return
        }
        keys.remove(entry.key)
    }
}
