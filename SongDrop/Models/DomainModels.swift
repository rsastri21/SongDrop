//
//  DomainModels.swift
//  SongDrop
//
//  Created by Rohan Sastri on 3/2/26.
//

import Foundation

// MARK: - Decoding Utility

@propertyWrapper
struct NilOnEmptyURL: Codable, Equatable, Hashable {
    var wrappedValue: URL?

    init(wrappedValue: URL?) {
        self.wrappedValue = wrappedValue
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        if !string.isEmpty {
            wrappedValue = URL(string: string)
        } else {
            wrappedValue = nil
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let url = wrappedValue {
            try container.encode(url.absoluteString)
        } else {
            try container.encodeNil()
        }
    }
}

// MARK: Artwork Protocol

protocol Displayable: Identifiable, Hashable {
    var id: String { get }
    var name: String { get }
    var thumbnail: URL { get }
    var art: URL { get }
}

// MARK: - Enums

enum ResourceType: String, Codable {
    case track
    case artist
    case album
}

enum Provider: String, CaseIterable, Codable, Comparable {
    static func < (lhs: Provider, rhs: Provider) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
    
    case spotify
    case appleMusic
}

// MARK: - Core Models

struct ShareUrl: Codable, Hashable {
    let spotify: URL?
    let appleMusic: URL?
}

struct Track: Codable, Hashable, Identifiable, Displayable {
    let id: String
    let name: String
    let artists: [String]
    let album: String
    let thumbnail: URL
    let art: URL
    let shareUrl: ShareUrl
    let type: ResourceType
}

struct Artist: Codable, Hashable, Identifiable {
    let id: String
    let name: String
    @NilOnEmptyURL var thumbnail: URL?
    @NilOnEmptyURL var art: URL?
    let shareUrl: ShareUrl
    let type: ResourceType
}

struct Album: Codable, Hashable, Identifiable, Displayable {
    let id: String
    let name: String
    let artist: String
    let thumbnail: URL
    let art: URL
    let shareUrl: ShareUrl
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

// MARK: - API Request Contract

struct TypeaheadRequest: Codable {
    let mode: SearchMode
    let provider: Provider
    let query: String
}

struct ResolveRequest: Codable {
    let mode: SearchMode
    let provider: Provider
    let type: ResourceType
    let query: String
}

enum SearchRequest: Codable {
    case typeahead(TypeaheadRequest)
    case resolve(ResolveRequest)

    private enum CodingKeys: String, CodingKey {
        case mode
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let mode = try container.decode(SearchMode.self, forKey: .mode)

        switch mode {
        case .typeahead:
            let request = try TypeaheadRequest(from: decoder)
            self = .typeahead(request)
        case .resolve:
            let request = try ResolveRequest(from: decoder)
            self = .resolve(request)
        }
    }

    func encode(to encoder: Encoder) throws {
        switch self {
        case .typeahead(let request):
            try request.encode(to: encoder)
        case .resolve(let request):
            try request.encode(to: encoder)
        }
    }
}

// MARK: - Encodable Extension

extension Encodable {
    var queryItems: [URLQueryItem] {
        guard let data = try? JSONEncoder().encode(self),
            let dict = try? JSONSerialization.jsonObject(with: data)
                as? [String: Any]
        else {
            return []
        }
        return dict.compactMap {
            URLQueryItem(name: $0.key, value: $0.value as? String)
        }
        .sorted { $0.name < $1.name }
    }
}
