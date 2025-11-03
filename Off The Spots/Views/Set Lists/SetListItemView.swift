//
//  SetListItemView.swift
//  Off The Spots
//
//  Created by David Freeman on 10/30/25.
//

import SwiftUI

struct SetListItemView: View {
    var setList: SetList
    var selectedSetList: SetList?
    var isSongPlaying: Bool = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(setList.name)
                    .font(.title2)
                    .tint(.primary)
                    .multilineTextAlignment(.leading)
                
                HStack {
                    Text("\(Image(systemName: "music.note")) \(setList.songs.count)")
                        .font(.footnote)
                        .tint(.primary)
                }
            }
            
            if selectedSetList != nil && selectedSetList!.id == setList.id {
                Spacer()
                AnimatedWaveformView(color: .accentColor, animate: isSongPlaying)
                    .scaleEffect(0.3)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    List {
        SetListItemView(setList: SetList(name: "Set List", songs: []))
        SetListItemView(setList: SetList(name: "Set List", songs: []))
        SetListItemView(setList: SetList(name: "Set List", songs: []))
        SetListItemView(setList: SetList(name: "Set List", songs: []))
        SetListItemView(setList: SetList(name: "Set List", songs: []))
    }
}
