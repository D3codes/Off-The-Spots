//
//  SetListListTemplate.swift
//  Off The Spots
//
//  Created by David Freeman on 11/16/25.
//

import CarPlay
import SwiftData

@MainActor
func setListListTemplate(setList: SetList, modelContext: ModelContext, interfaceController: CPInterfaceController?) -> CPListTemplate {
    let descriptor = FetchDescriptor<Song>(sortBy: [SortDescriptor(\.order, order: .forward)])
    let songs = (try? modelContext.fetch(descriptor)) ?? []
    
    var listItems: [CPListItem] = []
    setList.songs.forEach { songId in
        let song = songs.first(where: { $0.id == songId })!
        
        let songListItem = CPListItem(text: song.name, detailText: "")
        
        songListItem.handler = { listItem, completion in
            AudioHelper.sharedController.setSelectedSong(song: song, setList: setList)
            AudioHelper.sharedController.play()
            
            if let interfaceController = interfaceController {
                interfaceController.pushTemplate(CPNowPlayingTemplate.shared, animated: true) { success, error in
                     // optional completion handler once CarPlay UI is displayed
                }
            }
            
            completion()
        }
        
        listItems.append(songListItem)
    }
    
    let headerButton: CPButton = CPButton(image: UIImage(systemName: "play.fill")!, handler: { _ in
        let firstSong = songs.first(where: { $0.id == setList.songs.first})!
        
        AudioHelper.sharedController.setSelectedSong(song: firstSong, setList: setList)
        AudioHelper.sharedController.play()
        
        if let interfaceController = interfaceController {
            interfaceController.pushTemplate(CPNowPlayingTemplate.shared, animated: true) { success, error in
                 // optional completion handler once CarPlay UI is displayed
            }
        }
    })
    
    var setListListSection: CPListSection!
    var setListTemplate: CPListTemplate!
    if setList.songs.isEmpty {
        setListListSection = CPListSection(items: listItems)
        setListTemplate = CPListTemplate(title: setList.name, sections: [setListListSection])
    } else {
        setListListSection = CPListSection(items: listItems, header: setList.name, headerSubtitle: nil, headerImage: nil, headerButton: headerButton, sectionIndexTitle: nil)
        setListTemplate = CPListTemplate(title: "", sections: [setListListSection])
    }
    
    return setListTemplate
}
