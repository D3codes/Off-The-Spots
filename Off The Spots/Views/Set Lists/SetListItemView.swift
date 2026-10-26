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
    
    var isSearchResult: Bool = false
    var deleteSetList: () -> Void = {}
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(setList.name)
                    .font(.title2)
                    .tint(.primary)
                    .multilineTextAlignment(.leading)
                
                HStack(spacing: 4) {
                    if selectedSetList != nil && selectedSetList!.id == setList.id {
                        AnimatedWaveformView(color: .accentColor, animate: isSongPlaying)
                            .scaleEffect(0.2)
                            .frame(maxWidth: 10, maxHeight: 10)
                            .padding(.trailing, 4)
                    }
                    
                    Text("\(Image(systemName: "music.note"))")
                        .tint(.accentColor)
                        .font(.subheadline)
                    Text("\(setList.songs.count)")
                        .tint(.primary)
                        .font(.subheadline)
                }
            }
            
            if !isSearchResult {
                Spacer()
                
                Menu(content: {
                    Button(
                        action: { },
                        label: { Label("Edit Set List", systemImage: "pencil") }
                    )
                    
                    Divider()
                    
                    Button(role: .destructive) {
                        deleteSetList()
                    } label: {
                        Label("Delete Set List", systemImage: "trash")
                    }
                }, label: {
                    Image(systemName: "ellipsis")
                        .foregroundStyle(.foreground)
                        .frame(width: 20, height: 20)
                })
            }
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    List {
        SetListItemView(setList: SetList(name: "Set List", songs: []), deleteSetList: {})
        SetListItemView(setList: SetList(name: "Set List", songs: []), deleteSetList: {})
        SetListItemView(setList: SetList(name: "Set List", songs: []), deleteSetList: {})
        SetListItemView(setList: SetList(name: "Set List", songs: []), deleteSetList: {})
        SetListItemView(setList: SetList(name: "Set List", songs: []), deleteSetList: {})
    }
}
