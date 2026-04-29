//
//  ProviderStore.swift
//  SongDrop
//
//  Created by Rohan Sastri on 4/28/26.
//

import Foundation

@MainActor
@Observable
final class ProviderStore {
    
    private let endpoint: URL
    private static let userDefaultsKey = "selectedProvider"
    
    var selectedProvider: Provider {
        didSet {
            UserDefaults.standard.set(selectedProvider.rawValue, forKey: Self.userDefaultsKey)
        }
    }
    var availableProviders: [Provider] = Provider.allCases
    var isLoading: Bool = false
    
    init(apiConfig: APIConfig) {
        self.endpoint = apiConfig.providers
        let raw = UserDefaults.standard.string(forKey: Self.userDefaultsKey) ?? ""
        self.selectedProvider = Provider(rawValue: raw) ?? .appleMusic
    }
    
    func loadProviders() async {
        isLoading = true
        defer { isLoading = false }
        guard let (data, _) = try? await URLSession.shared.data(from: endpoint),
              let response = try? JSONDecoder().decode(ProviderResponse.self, from: data)
        else { return }
        availableProviders = response
    }
}
