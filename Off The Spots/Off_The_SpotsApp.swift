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
            return container
        } catch {
            print("CloudKit-backed ModelContainer unavailable, using local store: \(error)")
            let localConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

            do {
                let container = try ModelContainer(for: schema, configurations: [localConfiguration])
                return container
            } catch {
                fatalError("Could not create ModelContainer: \(error)")
            }
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
