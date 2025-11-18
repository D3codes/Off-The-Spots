//
//  SetListsListTemplate.swift
//  Off The Spots
//
//  Created by David Freeman on 11/12/25.
//

import CarPlay
import SwiftData

extension CarPlayTemplateManager {
    @MainActor
    func setListsListTemplate() -> CPListTemplate {
        let setListsTemplate = CPListTemplate(title: "Set Lists", sections: getSetListsListSections())
        setListsTemplate.tabTitle = "Set Lists"
        setListsTemplate.tabImage = UIImage(systemName: "music.note.list")
        
        return setListsTemplate
    }
    
    func getSetListsListSections() -> [CPListSection] {
        let descriptor = FetchDescriptor<SetList>(sortBy: [SortDescriptor(\.order, order: .forward)])
        let setLists = (try? modelContext.fetch(descriptor)) ?? []
        
        var listItems: [CPListItem] = []
        setLists.forEach { setList in
            let setListsListItem = CPListItem(text: setList.name, detailText: "\(setList.songs.count) Song\(setList.songs.count == 1 ? "" : "s")")
            setListsListItem.isPlaying = AudioHelper.sharedController.selectedSetList?.id == setList.id
            
            setListsListItem.handler = { listItem, completion in
                self.interfaceController.pushTemplate(self.setListListTemplate(setList: setList), animated: true) { success, error in
                    // optional completion handler once CarPlay UI is displayed
                }
                
                completion()
            }
            
//            setListsListItem.setAccessoryImage(UIImage(systemName: "chevron.right")!)
            listItems.append(setListsListItem)
        }
        
        return [CPListSection(items: listItems)]
    }
}
