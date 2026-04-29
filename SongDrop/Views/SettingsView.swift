//
//  SettingsView.swift
//  SongDrop
//
//  Created by Rohan Sastri on 4/28/26.
//

import SwiftUI

struct SettingsView: View {

    @Environment(ProviderStore.self) private var providerStore

    var body: some View {
        @Bindable var bindableProviderStore = providerStore

        NavigationStack {
            List {
                Section(
                    footer: Text(
                        "Choose a music service to use for searches and music artwork"
                    )
                ) {
                    Picker(
                        "Music Provider",
                        selection: $bindableProviderStore.selectedProvider
                    ) {
                        ForEach(
                            bindableProviderStore.availableProviders,
                            id: \.rawValue
                        ) { provider in
                            Text(provider.displayName)
                                .tag(provider)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
        .environment(ProviderStore(apiConfig: .init()))
}
