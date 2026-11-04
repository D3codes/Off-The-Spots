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
    func songsListTemplate(isPro: Bool) -> CPListTemplate {
        let songsTemplate = CPListTemplate(title: "Songs", sections: getSongsListSections(isPro: isPro))
        songsTemplate.tabTitle = "Songs"
        songsTemplate.tabImage = UIImage(systemName: "music.note")
        
        return songsTemplate
    }
    
    func getSongsListSections(isPro: Bool) -> [CPListSection] {
        let descriptor = FetchDescriptor<Song>(sortBy: [SortDescriptor(\.order, order: .forward)])
        let songs = (try? modelContext.fetch(descriptor)) ?? []
        
        var listItems: [CPListItem] = []
        if isPro {
            songs.forEach { song in
                let songListItem = CPListItem(text: song.name, detailText: "\(song.trackCount) Track\(song.trackCount > 1 ? "s" : "")")
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
        } else {
            for i in 0...2 {
                if songs.count > i {
                    let song = songs[i]
                    
                    let songListItem = CPListItem(text: song.name, detailText: "\(song.trackCount) Track\(song.trackCount > 1 ? "s" : "")")
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
            }
            
            if songs.count > 3 {
                let subscriptionListItem = CPListItem(text: "Off The Spots Pro Required", detailText: "Subscribe to Pro to unlock more Songs")
                subscriptionListItem.setImage(UIImage(named: "icon"))
                
                subscriptionListItem.handler = { listItem, completion in
                    completion()
                }
                
                listItems.append(subscriptionListItem)
            }
        }
        
        let songsListSection = CPListSection(items: listItems)
        
        return [songsListSection]
    }
}
