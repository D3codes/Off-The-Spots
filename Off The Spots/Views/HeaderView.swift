//
//  HeaderView.swift
//  Off The Spots
//
//  Created by David Freeman on 12/3/24.
//

import SwiftUI

struct HeaderView: View {
    @Binding var presentSettingsSheet: Bool
    var songs: [Song]
    var addItem: () -> Void
    
    var body: some View {
        HStack {
            Button(action: { presentSettingsSheet = true }, label: {
                Image(systemName: "gearshape")
                    .font(.title2)
            })
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("Off The Spots")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .center)
            
            HStack {
                Button(action: { addItem() }, label: {
                    Image(systemName: "plus")
                        .font(.title2)
                })
                
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
        @State private var presentSettingsSheet = false
        @State private var songs: [Song] = []
        
        var body: some View {
            HeaderView(presentSettingsSheet: $presentSettingsSheet, songs: songs, addItem: {})
        }
    }
    
    return HeaderView_Preview()
}
