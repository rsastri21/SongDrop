//
//  MockURLSession.swift
//  SongDropTests
//
//  Created by Rohan Sastri on 3/7/26.
//

import Foundation
import Testing

@testable import SongDrop

enum MockURLSessionError: Error {
    case noStubbedData
    case noStubbedDownload
}

final class URLSessionMock: URLSessionProtocol {
    
    // MARK: - Stubs
    
    var dataResult: Result<(Data, URLResponse), Error>?
    var downloadResult: Result<(URL, URLResponse), Error>?
    
    // MARK: - Recording
    
    private var continuation: CheckedContinuation<(Data, URLResponse), Error>?
    private(set) var dataCallCount: Int = 0
    
    private(set) var lastDownloadURL: URL?
    private(set) var downloadCallCount: Int = 0
    
    func data(for request: URLRequest, delegate: (any URLSessionTaskDelegate)?) async throws -> (Data, URLResponse) {
        dataCallCount += 1
        
        return try await withCheckedThrowingContinuation { cont in
            self.continuation = cont
        }
    }
    
    func download(from url: URL, delegate: (any URLSessionTaskDelegate)?) async throws -> (URL, URLResponse) {
        lastDownloadURL = url
        downloadCallCount += 1
        
        guard let downloadResult else {
            throw MockURLSessionError.noStubbedDownload
        }
        
        switch downloadResult {
        case .success(let response):
            return response
        case .failure(let error):
            throw error
        }
    }
    
    func complete(with data: Data, response: URLResponse) {
        continuation?.resume(returning: (data, response))
        continuation = nil
    }
}
