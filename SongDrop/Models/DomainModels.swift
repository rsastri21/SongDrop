//
//  DomainModels.swift
//  SongDrop
//
//  Created by Rohan Sastri on 3/2/26.
//

import Foundation

// MARK: - Enums

enum ResourceType: String, Codable {
    case track
    case artist
    case album
}

enum Provider: String, Codable {
    case spotify
    case appleMusic
}

// MARK: - Core Models

struct Track: Codable {
    let id: String
    let name: String
    let artists: [String]
    let album: String
    let thumbnail: URL
    let art: URL
    let shareUrl: URL
    let type: ResourceType
}

struct Artist: Codable {
    let id: String
    let name: String
    let thumbnail: URL
    let art: URL
    let shareUrl: URL
    let type: ResourceType
}

struct Album: Codable {
    let id: String
    let name: String
    let artist: String
    let thumbnail: URL
    let art: URL
    let shareUrl: URL
    let type: ResourceType
}

// MARK: - API Response Contract

enum SearchMode: String, Codable {
    case typeahead
    case resolve
}

struct TypeaheadResponse: Codable {
    let mode: SearchMode
    let tracks: [Track]
    let artists: [Artist]
    let albums: [Album]
    let from: Provider
}

struct ResolveResponse: Codable {
    let mode: SearchMode
    let item: ResolveItem
    let from: Provider
}

enum SearchResponse: Codable {
    case typeahead(TypeaheadResponse)
    case resolve(ResolveResponse)
    
    private enum CodingKeys: String, CodingKey {
        case mode
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let mode = try container.decode(SearchMode.self, forKey: .mode)
        
        switch mode {
        case .typeahead:
            let response = try TypeaheadResponse(from: decoder)
            self = .typeahead(response)
        case .resolve:
            let response = try ResolveResponse(from: decoder)
            self = .resolve(response)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        switch self {
        case .typeahead(let typeaheadResponse):
            try typeaheadResponse.encode(to: encoder)
        case .resolve(let resolveResponse):
            try resolveResponse.encode(to: encoder)
        }
    }
}

enum ResolveItem: Codable {
    case track(Track)
    case artist(Artist)
    case album(Album)
    
    private enum CodingKeys: String, CodingKey {
        case type
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let itemType = try container.decode(ResourceType.self, forKey: .type)
        
        switch itemType {
        case .track:
            let track = try Track(from: decoder)
            self = .track(track)
        case .artist:
            let artist = try Artist(from: decoder)
            self = .artist(artist)
        case .album:
            let album = try Album(from: decoder)
            self = .album(album)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        switch self {
        case .track(let track):
            try track.encode(to: encoder)
        case .artist(let artist):
            try artist.encode(to: encoder)
        case .album(let album):
            try album.encode(to: encoder)
        }
    }
}
