//
//  UpNextTemplate.swift
//  Off The Spots
//
//  Created by David Freeman on 11/17/25.
//

import CarPlay
import SwiftData

extension CarPlayTemplateManager {
    @MainActor
    func upNextTemplate(setList: SetList) -> CPListTemplate {
        let descriptor = FetchDescriptor<Song>(sortBy: [SortDescriptor(\.order, order: .forward)])
        let songs = (try? modelContext.fetch(descriptor)) ?? []
        
        var listItems: [CPListItem] = []
        setList.songs.forEach { songId in
            let song = songs.first(where: { $0.id == songId })!
            
            let songListItem = CPListItem(text: song.name, detailText: "")
            songListItem.isPlaying = AudioHelper.sharedController.selectedSong?.id == song.id && AudioHelper.sharedController.selectedSetList?.id == setList.id
            
            songListItem.handler = { listItem, completion in
                AudioHelper.sharedController.setSelectedSong(song: song, setList: setList)
                AudioHelper.sharedController.play()
                
                CPNowPlayingTemplate.shared.isUpNextButtonEnabled = true
                self.interfaceController.popTemplate(animated: true) { success, error in
                    // optional completion handler once CarPlay UI is displayed
                }
                
                completion()
            }
            
            listItems.append(songListItem)
        }
        
        let upNextListSection = CPListSection(items: listItems)
        let upNextTemplate = CPListTemplate(title: setList.name, sections: [upNextListSection])
        
        return upNextTemplate
    }
}
