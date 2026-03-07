//
//  NetworkClient.swift
//  SongDrop
//
//  Created by Rohan Sastri on 3/6/26.
//

import Foundation

struct NetworkClient {
    
    enum NetworkError: Error {
        case invalidResponse
        case badStatus(Int)
        case decoding(Error)
    }
    
    private let session: URLSession
    private let baseUrl: URL
    
    init(session: URLSession = .shared, baseUrl: URL) {
        self.session = session
        self.baseUrl = baseUrl
    }
    
    func get<T: Decodable>(
        path: String,
        queryItems: [URLQueryItem] = [],
    ) async throws -> T {
        
        var components = URLComponents(
            url: baseUrl.appending(path: path),
            resolvingAgainstBaseURL: false
        )
        components?.queryItems = queryItems
        
        guard let url = components?.url else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let http = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard 200..<300 ~= http.statusCode else {
            throw NetworkError.badStatus(http.statusCode)
        }
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw NetworkError.decoding(error)
        }
    }
}
