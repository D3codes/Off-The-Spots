//
//  CarPlayTemplateManager.swift
//  Off The Spots
//
//  Created by David Freeman on 11/16/25.
//

import CarPlay
import SwiftData

@MainActor
final class CarPlayTemplateManager: NSObject {
    let container: ModelContainer
    let modelContext: ModelContext
    let interfaceController: CPInterfaceController

    init(interfaceController: CPInterfaceController) {
        self.interfaceController = interfaceController
        
        container = {
            let schema = Schema([
                Song.self,
                SetList.self
            ])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

            do {
                return try ModelContainer(for: schema, configurations: [modelConfiguration])
            } catch {
                fatalError("Could not create ModelContainer: \(error)")
            }
        }()
        
        modelContext = ModelContext(container)
    }
    
    func connect() -> Void {
        interfaceController.delegate = self
        CPNowPlayingTemplate.shared.isAlbumArtistButtonEnabled = true
        CPNowPlayingTemplate.shared.add(self)
        self.setNowPlayingButtons()
    }
    
    func disconnect() -> Void {
        AudioHelper.sharedController.pause()
    }
}
