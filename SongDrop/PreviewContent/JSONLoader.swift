//
//  JSONLoader.swift
//  SongDrop
//
//  Created by Rohan Sastri on 3/7/26.
//

import Foundation

enum JSONLoader {
    static func loadSearchResponse(
        named fileName: String,
        in bundle: Bundle = .main
    ) -> SearchResponse? {
        guard let url = bundle.url(forResource: fileName, withExtension: "json") else {
            assertionFailure("Missing JSON file: \(fileName).json")
            return nil
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            // configure decoder if needed (dateDecodingStrategy, etc.)
            return try decoder.decode(SearchResponse.self, from: data)
        } catch {
            assertionFailure("Failed to decode \(fileName).json: \(error)")
            return nil
        }
    }
}
