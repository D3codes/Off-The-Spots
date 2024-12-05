//
//  HeaderView.swift
//  Off The Spots
//
//  Created by David Freeman on 12/3/24.
//

import SwiftUI

struct HeaderView: View {
    var songs: [Song]
    @Binding var presentSettingsSheet: Bool
    @Binding var presentAddSongPopover: Bool
    
    var body: some View {
        HStack {
            Button(action: { presentSettingsSheet = true }, label: {
                Image(systemName: "gearshape")
                    .font(.title2)
            })
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityLabel("Settings")
            
            Text("Off The Spots")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .center)
            
            HStack {
                Button(action: { presentAddSongPopover = true }, label: {
                    Image(systemName: "plus")
                        .font(.title2)
                })
                .accessibilityLabel("Add Song")
                
                if(!songs.isEmpty) {
                    EditButton()
                        .font(.title2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 15)
        .background(.thickMaterial)
    }
}

#Preview {
    struct HeaderView_Preview: View {
        @State private var songs: [Song] = []
        @State private var presentSettingsSheet = false
        @State private var presentAddSongPopover = false
        
        var body: some View {
            HeaderView(
                songs: songs,
                presentSettingsSheet: $presentSettingsSheet,
                presentAddSongPopover: $presentAddSongPopover
            )
        }
    }
    
    return HeaderView_Preview()
}
