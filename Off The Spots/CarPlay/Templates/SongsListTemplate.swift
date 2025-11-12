//
//  SongsListTemplate.swift
//  Off The Spots
//
//  Created by David Freeman on 11/12/25.
//

import CarPlay

@MainActor
func songsListTemplate() -> CPListTemplate {
    let listItems: [CPListItem] = [
        CPListItem(text: "Song 1", detailText: "Song 1 detail"),
        CPListItem(text: "Song 2", detailText: "Song 2 detail"),
        CPListItem(text: "Song 3", detailText: "Song 3 detail"),
        CPListItem(text: "Song 4", detailText: "Song 4 detail"),
        CPListItem(text: "Song 5", detailText: "Song 5 detail"),
    ]
    
//    var listItems: [CPListItem] = []
//    songs.forEach { song in
//        let songListItem = CPListItem(text: song.name, detailText: song.name)
//        listItems.append(songListItem)
//        if true {
//            songListItem.setImage(UIImage(systemName: "waveform")!)
//        }
//    }
    
    let songsListSection = CPListSection(items: listItems)
    let songsTemplate = CPListTemplate(title: "Songs", sections: [songsListSection])
    songsTemplate.tabImage = UIImage(systemName: "music.note")
    
    return songsTemplate
}
