//
//  SongsListTemplate.swift
//  Off The Spots
//
//  Created by David Freeman on 11/12/25.
//

import CarPlay
import SwiftData

extension CarPlayTemplateManager {
    @MainActor
    func songsListTemplate() -> CPListTemplate {
        let songsTemplate = CPListTemplate(title: "Songs", sections: getSongsListSections())
        songsTemplate.tabTitle = "Songs"
        songsTemplate.tabImage = UIImage(systemName: "music.note")
        
        return songsTemplate
    }
    
    func getSongsListSections() -> [CPListSection] {
        let descriptor = FetchDescriptor<Song>(sortBy: [SortDescriptor(\.order, order: .forward)])
        let songs = (try? modelContext.fetch(descriptor)) ?? []
        
        var listItems: [CPListItem] = []
        songs.forEach { song in
            let songListItem = CPListItem(text: song.name, detailText: "\(song.tracks.count) Track\(song.tracks.count > 1 ? "s" : "")")
            songListItem.isPlaying = AudioHelper.sharedController.selectedSong?.id == song.id && AudioHelper.sharedController.selectedSetList == nil
            
            songListItem.handler = { listItem, completion in
                AudioHelper.sharedController.setSelectedSong(song: song, setList: nil)
                AudioHelper.sharedController.play()
                
                CPNowPlayingTemplate.shared.isUpNextButtonEnabled = false
                self.interfaceController.pushTemplate(CPNowPlayingTemplate.shared, animated: true) { success, error in
                    // optional completion handler once CarPlay UI is displayed
                }
                
                completion()
            }
            
            listItems.append(songListItem)
        }
        
        let songsListSection = CPListSection(items: listItems)
        
        return [songsListSection]
    }
}
