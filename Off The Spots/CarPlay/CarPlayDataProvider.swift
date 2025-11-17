//
//  CarPlayDataProvider.swift
//  Off The Spots
//
//  Created by David Freeman on 11/16/25.
//

import CarPlay
import SwiftData

final class CarPlayDataProvider {
    let container: ModelContainer
    let context: ModelContext

    init() {
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
        
        context = ModelContext(container)
    }

    @MainActor
    func makeSongsTemplate(interfaceController: CPInterfaceController?) -> CPListTemplate {
        songsListTemplate(modelContext: context, interfaceController: interfaceController)
    }
    
    @MainActor
    func makeSetListsTemplate(interfaceController: CPInterfaceController?) -> CPListTemplate {
        setListsListTemplate(modelContext: context, interfaceController: interfaceController)
    }
    
    @MainActor
    func makeSetListTemplate(setList: SetList, interfaceController: CPInterfaceController?) -> CPListTemplate {
        setListListTemplate(setList: setList, modelContext: context, interfaceController: interfaceController)
    }
}
