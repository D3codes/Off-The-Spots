//
//  Off_The_SpotsApp.swift
//  Off The Spots
//
//  Created by David Freeman on 5/12/23.
//

import SwiftUI

@main
struct Off_The_SpotsApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
