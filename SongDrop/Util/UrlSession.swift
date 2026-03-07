//
//  UrlSession.swift
//  SongDrop
//
//  Created by Rohan Sastri on 3/7/26.
//

import Foundation

protocol URLSessionProtocol {
    func data(
        for request: URLRequest,
        delegate: (any URLSessionTaskDelegate)?
    ) async throws -> (Data, URLResponse)
    
    func download(
        from url: URL,
        delegate: (any URLSessionTaskDelegate)?
    ) async throws -> (URL, URLResponse)
}

extension URLSession: URLSessionProtocol {}
