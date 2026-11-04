//
//  TracksListTemplate.swift
//  Off The Spots
//
//  Created by David Freeman on 11/17/25.
//

import CarPlay

extension CarPlayTemplateManager {
    @MainActor
    func tracksListTemplate(song: Song, isPro: Bool) -> CPListTemplate {
        var listItems: [CPListItem] = []
        if isPro {
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
        } else {
            for i in 0...1 {
                if song.sortedTracks.count > i {
                    let track = song.sortedTracks[i]
                    
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
            }
            
            if song.sortedTracks.count > 2 {
                let subscriptionListItem = CPListItem(text: "Off The Spots Pro Required", detailText: "Subscribe to Pro to unlock more Tracks")
                subscriptionListItem.setImage(UIImage(named: "icon"))
                
                subscriptionListItem.handler = { listItem, completion in
                    completion()
                }

                listItems.append(subscriptionListItem)
            }
        }
        
        let tracksListSection = CPListSection(items: listItems)
        let tracksListTemplate = CPListTemplate(title: "Tracks", sections: [tracksListSection])
        
        return tracksListTemplate
    }
}
