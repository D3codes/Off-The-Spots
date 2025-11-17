//
//  SongsListTemplate.swift
//  Off The Spots
//
//  Created by David Freeman on 11/12/25.
//

import CarPlay
import SwiftData

@MainActor
func songsListTemplate(modelContext: ModelContext, interfaceController: CPInterfaceController?) -> CPListTemplate {

    let descriptor = FetchDescriptor<Song>(sortBy: [SortDescriptor(\.order, order: .forward)])
    let songs = (try? modelContext.fetch(descriptor)) ?? []
    
    var listItems: [CPListItem] = []
    songs.forEach { song in
        let songListItem = CPListItem(text: song.name, detailText: "")
        
        songListItem.handler = { listItem, completion in
            AudioHelper.sharedController.setSelectedSong(song: song, setList: nil)
            AudioHelper.sharedController.play()
            
            if let interfaceController = interfaceController {
                interfaceController.pushTemplate(CPNowPlayingTemplate.shared, animated: true) { success, error in
                     // optional completion handler once CarPlay UI is displayed
                }
            }
            
            completion()
        }
        
//        if AudioHelper.sharedController.selectedSong?.id == song.id {
//            songListItem.setImage(UIImage(systemName: "waveform")!)
//        }
        listItems.append(songListItem)
    }
    
    let songsListSection = CPListSection(items: listItems)
    let songsTemplate = CPListTemplate(title: "Songs", sections: [songsListSection])
    songsTemplate.tabImage = UIImage(systemName: "music.note")
    
    return songsTemplate
}
