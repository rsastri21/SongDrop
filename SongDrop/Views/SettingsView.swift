//
//  SettingsView.swift
//  SongDrop
//
//  Created by Rohan Sastri on 4/28/26.
//

import SwiftUI

struct SettingsView: View {

    @Environment(CacheCoordinator.self) private var cacheCoordinator
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
                Section("Storage") {
                    if let info = cacheCoordinator.storageInfo {
                        StorageBarView(info: info)
                            .padding(.vertical, 8)
                    } else {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    }
                }
                Section {
                    Button("Clear Cache", role: .destructive) {
                        Task { await cacheCoordinator.clearAll() }
                    }
                    .frame(maxWidth: .infinity)
                    .disabled(cacheCoordinator.isClearing)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Settings")
        }
        .task {
            await cacheCoordinator.refreshStorageInfo()
        }
    }
}

#Preview {
    SettingsView()
        .environment(ProviderStore(apiConfig: .init()))
        .environment(CacheCoordinator(searchCache: .init()))
}
