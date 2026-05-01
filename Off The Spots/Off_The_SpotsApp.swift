//
//  Off_The_SpotsApp.swift
//  Off The Spots
//
//  Created by David Freeman on 12/3/24.
//

import SwiftUI
import SwiftData

enum OffTheSpotsPersistence {
    static let cloudKitContainerIdentifier = "iCloud.codes.d3.Off-The-Spots"
    static let maximumCloudKitAssetSize = 249 * 1024 * 1024

    static var schema: Schema {
        Schema([
            Song.self,
            SetList.self
        ])
    }

    static func makeModelContainer() -> ModelContainer {
        let schema = Self.schema

        do {
            let cloudConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .private(Self.cloudKitContainerIdentifier)
            )
            let container = try ModelContainer(for: schema, configurations: [cloudConfiguration])
            normalizeTrackOrders(in: container)
            return container
        } catch {
            print("CloudKit-backed ModelContainer unavailable, using local store: \(error)")
            let localConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

            do {
                let container = try ModelContainer(for: schema, configurations: [localConfiguration])
                normalizeTrackOrders(in: container)
                return container
            } catch {
                fatalError("Could not create ModelContainer: \(error)")
            }
        }
    }

    private static func normalizeTrackOrders(in container: ModelContainer) {
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<Song>()
        guard let songs = try? context.fetch(descriptor) else { return }

        var didChange = false
        for song in songs {
            guard let tracks = song.tracks, tracks.count > 1 else { continue }

            let orders = tracks.map(\.order)
            let hasDuplicateOrders = Set(orders).count != orders.count
            let hasContiguousOrders = Set(orders) == Set(0..<tracks.count)

            if hasDuplicateOrders || !hasContiguousOrders {
                for (index, track) in tracks.enumerated() {
                    if track.order != index {
                        track.order = index
                        didChange = true
                    }
                }
            }
        }

        if didChange {
            try? context.save()
        }
    }
}

@main
struct Off_The_SpotsApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var sharedModelContainer: ModelContainer = {
        OffTheSpotsPersistence.makeModelContainer()
    }()

    var body: some Scene {
        WindowGroup {
            MainView()
                .frame(minHeight: 800)
        }
        .modelContainer(sharedModelContainer)
        .windowResizability(.contentSize)
    }
}
