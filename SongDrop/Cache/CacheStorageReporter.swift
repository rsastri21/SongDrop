//
//  CacheStorageReporter.swift
//  SongDrop
//
//  Created by Rohan Sastri on 5/1/26.
//

import Foundation
import SwiftUI

struct CacheStorageSegment: Identifiable {
    let id = UUID()
    let name: String
    let bytes: Int64
    let color: Color

    var formattedSize: String {
        ByteCountFormatter.string(fromByteCount: bytes, countStyle: .file)
    }
}

struct CacheStorageInfo {
    let segments: [CacheStorageSegment]
    var totalBytes: Int64 { segments.reduce(0) { $0 + $1.bytes } }
    var isEmpty: Bool { totalBytes == 0 }
}

struct CacheStorageReporter {

    private static var cachesDirectory: URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    }

    static func calculate() -> CacheStorageInfo {
        let imageBytes = directorySize(at: cachesDirectory.appendingPathComponent("imagecache"))
        let networkBytes = networkCacheSize()
        
        var segments: [CacheStorageSegment] = []
        if imageBytes > 0 {
            segments.append(CacheStorageSegment(name: "Images", bytes: imageBytes, color: .green))
        }
        if networkBytes > 0 {
            segments.append(CacheStorageSegment(name: "Network", bytes: networkBytes, color: .blue))
        }
        return CacheStorageInfo(segments: segments)
    }

    private static func networkCacheSize() -> Int64 {
        guard
            let files = try? FileManager.default.contentsOfDirectory(
                at: cachesDirectory,
                includingPropertiesForKeys: [.fileSizeKey],
                options: .skipsHiddenFiles
            )
        else { return 0 }
        return
            files
            .filter { $0.pathExtension == "cache" }
            .reduce(0) { $0 + fileSize(at: $1) }
    }

    private static func directorySize(at url: URL) -> Int64 {
        guard
            let files = try? FileManager.default.contentsOfDirectory(
                at: url,
                includingPropertiesForKeys: [.fileSizeKey],
                options: .skipsHiddenFiles
            )
        else { return 0 }
        return files.reduce(0) { $0 + fileSize(at: $1) }
    }

    private static func fileSize(at url: URL) -> Int64 {
        guard
            let size = try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize
        else { return 0 }
        return Int64(size)
    }
}
