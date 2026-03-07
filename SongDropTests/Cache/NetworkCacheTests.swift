//
//  NetworkCacheTests.swift
//  SongDropTests
//
//  Created by Rohan Sastri on 3/7/26.
//

import Foundation
import Testing

@testable import SongDrop

@MainActor
struct NetworkCacheTests {
    var mockCache: MockCache<String>!
    var mockSession: URLSessionMock!
    var networkCache: NetworkCache<String>!

    init() async throws {
        mockCache = MockCache()
        mockSession = URLSessionMock()
        networkCache = NetworkCache(cache: mockCache, urlSession: mockSession)
    }

    @Test func get_returnsFromLocalWhenCached() async throws {
        let key = "http://example.com"
        await mockCache.set("test-cached", forKey: key)

        let url = URL(string: key)!
        let cached = try await networkCache.get(from: URLRequest(url: url))

        #expect(cached == "test-cached")
    }

    @Test func get_waitsOnInflightRequest() async throws {
        let key = "http://example.com"
        let url = URL(string: key)!
        let request = URLRequest(url: url)

        let firstTask = Task {
            try await networkCache.get(from: request)
        }
        try await Task.sleep(nanoseconds: 50_000_000)  // 50ms
        let secondTask = Task {
            try await networkCache.get(from: request)
        }

        let responseString = "test-inflight"
        let encoded = try JSONEncoder().encode(responseString)
        let response = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        mockSession.complete(with: encoded, response: response)
        
        let firstResponse = try await firstTask.value
        let secondResponse = try await secondTask.value
        
        #expect(firstResponse == responseString)
        #expect(secondResponse == responseString)
        #expect(mockSession.dataCallCount == 1)
    }
    
    @Test func get_makesRequestWhenUncached() async throws {
        let key = "http://example.com"
        let url = URL(string: key)!
        let request = URLRequest(url: url)
        
        let task = Task {
            try await networkCache.get(from: request)
        }
        try await Task.sleep(nanoseconds: 50_000_000)  // 50ms

        let responseString = "test-response"
        let encoded = try JSONEncoder().encode(responseString)
        let response = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        mockSession.complete(with: encoded, response: response)
        
        let resp = try await task.value
        let setCalls = await mockCache.setCalls.count
        
        #expect(resp == responseString)
        #expect(mockSession.dataCallCount == 1)
        #expect(setCalls == 1)
    }

}
