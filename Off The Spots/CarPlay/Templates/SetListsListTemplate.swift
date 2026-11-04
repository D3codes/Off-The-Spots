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
    func setListsListTemplate(isPro: Bool) -> CPListTemplate {
        let setListsTemplate = CPListTemplate(title: "Set Lists", sections: getSetListsListSections(isPro: isPro))
        setListsTemplate.tabTitle = "Set Lists"
        setListsTemplate.tabImage = UIImage(systemName: "music.note.list")
        
        return setListsTemplate
    }
    
    func getSetListsListSections(isPro: Bool) -> [CPListSection] {
        let descriptor = FetchDescriptor<SetList>(sortBy: [SortDescriptor(\.order, order: .forward)])
        let setLists = (try? modelContext.fetch(descriptor)) ?? []
        
        var listItems: [CPListItem] = []
        if isPro {
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
        } else {
            let subscriptionListItem = CPListItem(text: "Off The Spots Pro Required", detailText: "Subscribe to Pro to unlock Set Lists")
            subscriptionListItem.setImage(UIImage(named: "icon"))
            
            subscriptionListItem.handler = { listItem, completion in
                completion()
            }
            
            listItems.append(subscriptionListItem)
        }
        
        return [CPListSection(items: listItems)]
    }
}
