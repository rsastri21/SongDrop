//
//  APIConfig.swift
//  SongDrop
//
//  Created by Rohan Sastri on 3/7/26.
//

import Foundation

struct APIConfig {
    private let baseURL: URL
    
    var search: URL {
        baseURL.appendingPathComponent("v1").appendingPathComponent("search")
    }
    
    var providers: URL {
        baseURL.appendingPathComponent("v1").appendingPathComponent("providers")
    }
    
    init() {
        var apiUrl = "https://backend-production-44c1.up.railway.app"
        
        #if DEBUG
        apiUrl = "http://localhost:3000"
        #endif
        
        baseURL = URL(string: apiUrl)!
    }
}
