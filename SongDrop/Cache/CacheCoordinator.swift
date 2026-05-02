//
//  CacheCoordinator.swift
//  SongDrop
//
//  Created by Rohan Sastri on 5/1/26.
//

import Foundation
import Observation

@Observable
final class CacheCoordinator {
    var storageInfo: CacheStorageInfo? = nil
    var isClearing: Bool = false
    
    private let searchCache: NetworkCache<SearchResponse>
    
    init(searchCache: NetworkCache<SearchResponse>) {
        self.searchCache = searchCache
    }
    
    func refreshStorageInfo() async {
        storageInfo = await Task.detached(priority: .background) {
            await CacheStorageReporter.calculate()
        }.value
    }
    
    func clearAll() async {
        isClearing = true
        await searchCache.invalidate()
        try? await ImageCache.shared.clearAll()
        await refreshStorageInfo()
        isClearing = false
    }
}
