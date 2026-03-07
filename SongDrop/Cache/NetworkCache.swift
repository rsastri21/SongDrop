//
//  NetworkCache.swift
//  SongDrop
//
//  Created by Rohan Sastri on 3/3/26.
//

import Foundation

enum NetworkError: Error {
    case urlError
    case httpError(message: String)
    case fetchError(error: Error)
}

protocol NetworkCaching: Actor {
    associatedtype V: Codable
    func get(from urlRequest: URLRequest) async throws -> V?
    func getRecent(count: Int) async -> [V]
    func invalidate() async
}

actor NetworkCache<V: Codable>: NetworkCaching {
    
    private let cache: Cache<V>
    private var inflightTasks: [String: Task<V, Error>] = [:]
    private let decoder: JSONDecoder
    private let urlSession: URLSession
    
    init(cache: Cache<V> = .init(filename: "networkcache"), decoder: JSONDecoder = .init(), urlSession: URLSession = .shared) {
        self.cache = cache
        self.decoder = decoder
        self.urlSession = urlSession
    }
    
    func get(from urlRequest: URLRequest) async throws -> V? {
        guard let urlString = urlRequest.url?.absoluteString else {
            throw NetworkError.urlError
        }
        
        // Case 1: Data is cached
        if let cached = await cache.get(forKey: urlString) {
            return cached
        }
        
        // Case 2: Data is being fetched
        if let task = inflightTasks[urlString] {
            return try await task.value
        }
        
        // Case 3: Fresh request
        let task = createTask(request: urlRequest, forKey: urlString)
        inflightTasks[urlString] = task
        
        do {
            let value = try await task.value
            await cache.set(value, forKey: urlString)
            return value
        } catch {
            await cache.remove(forKey: urlString)
            throw NetworkError.fetchError(error: error)
        }
    }
    
    func getRecent(count: Int) async -> [V] {
        return await cache.getRecent(count: count)
    }
    
    func invalidate() async {
        await cache.removeAll()
    }
    
    private func createTask(request: URLRequest, forKey key: String) -> Task<V, Error> {
        return Task<V, Error> {
            defer { Task { removeTask(for: key) } }
            
            let (data, response) = try await urlSession.data(for: request)
            guard let resp = response as? HTTPURLResponse, (200...299).contains(resp.statusCode) else {
                throw NetworkError.httpError(message: "Invalid response code")
            }
            let value = try decoder.decode(V.self, from: data)
            return value
        }
    }
    
    private func removeTask(for url: String) {
        inflightTasks[url] = nil
    }
}
