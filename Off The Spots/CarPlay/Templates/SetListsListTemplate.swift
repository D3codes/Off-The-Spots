//
//  SetListsListTemplate.swift
//  Off The Spots
//
//  Created by David Freeman on 11/12/25.
//

import CarPlay
import SwiftData

@MainActor
func setListsListTemplate(modelContext: ModelContext, interfaceController: CPInterfaceController?) -> CPListTemplate {
    let descriptor = FetchDescriptor<SetList>(sortBy: [SortDescriptor(\.order, order: .forward)])
    let setLists = (try? modelContext.fetch(descriptor)) ?? []
    
    var listItems: [CPListItem] = []
    setLists.forEach { setList in
        let setListsListItem = CPListItem(text: setList.name, detailText: "")
        
        setListsListItem.handler = { listItem, completion in
            if let interfaceController = interfaceController {
                interfaceController.pushTemplate(CarPlayDataProvider().makeSetListTemplate(setList: setList, interfaceController: interfaceController), animated: true) { success, error in
                     // optional completion handler once CarPlay UI is displayed
                }
            }
            
            completion()
        }
        
        setListsListItem.setAccessoryImage(UIImage(systemName: "chevron.right")!)
        listItems.append(setListsListItem)
    }
    
    let setListsListSection = CPListSection(items: listItems)
    let setListsTemplate = CPListTemplate(title: "Set Lists", sections: [setListsListSection])
    setListsTemplate.tabImage = UIImage(systemName: "music.note.list")
    
    return setListsTemplate
}
