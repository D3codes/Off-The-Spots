//
//  TracksListTemplate.swift
//  Off The Spots
//
//  Created by David Freeman on 11/17/25.
//

import CarPlay

extension CarPlayTemplateManager {
    @MainActor
    func tracksListTemplate(song: Song) -> CPListTemplate {
        var listItems: [CPListItem] = []
        song.sortedTracks.forEach { track in
            let trackListItem = CPListItem(text: track.name, detailText: "")
            
            trackListItem.handler = { listItem, completion in
                AudioHelper.sharedController.setSelectedTrack(track: track)
//                AudioHelper.sharedController.play()
                
                self.interfaceController.popTemplate(animated: true) { success, error in
                    // optional completion handler once CarPlay UI is displayed
                }
                
                completion()
            }
            
            listItems.append(trackListItem)
        }
        
        let tracksListSection = CPListSection(items: listItems)
        let tracksListTemplate = CPListTemplate(title: "Tracks", sections: [tracksListSection])
        
        return tracksListTemplate
    }
}
