//
//  SetListItemView.swift
//  Off The Spots
//
//  Created by David Freeman on 10/30/25.
//

import SwiftUI

struct SetListItemView: View {
    var setList: SetList
    
    var body: some View {
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
