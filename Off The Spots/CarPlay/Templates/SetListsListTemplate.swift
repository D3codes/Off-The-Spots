//
//  SetListsListTemplate.swift
//  Off The Spots
//
//  Created by David Freeman on 11/12/25.
//

import CarPlay

@MainActor
func setListsListTemplate() -> CPListTemplate {
    let listItems: [CPListItem] = [
        CPListItem(text: "Set List 1", detailText: "Set List 1 detail"),
        CPListItem(text: "Set List 2", detailText: "Set List 2 detail"),
        CPListItem(text: "Set List 3", detailText: "Set List 3 detail"),
        CPListItem(text: "Set List 4", detailText: "Set List 4 detail"),
        CPListItem(text: "Set List 5", detailText: "Set List 5 detail"),
    ]
    
    let setListsListSection = CPListSection(items: listItems)
    let setListsTemplate = CPListTemplate(title: "Set Lists", sections: [setListsListSection])
    setListsTemplate.tabImage = UIImage(systemName: "music.note.list")
    
    return setListsTemplate
}
