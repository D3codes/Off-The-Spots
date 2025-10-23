//
//  SetListsView.swift
//  Off The Spots
//
//  Created by David Freeman on 7/16/25.
//

import SwiftUI

struct SetListsView: View {
    @Binding var hideMiniPlayer: Bool
    
    var body: some View {
        NavigationStack {
            Text("Set Lists")
                .navigationTitle("Set Lists")
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        NavigationLink(destination: SettingsView(hideMiniPlayer: $hideMiniPlayer), label: {Image(systemName: "gearshape") })
                    }
                }
                .onAppear { hideMiniPlayer = false }
        }
    }
}

#Preview {
    struct SetListsView_Preview: View {
        @State private var hideMiniPlayer: Bool = false
        
        var body: some View {
            SetListsView(hideMiniPlayer: $hideMiniPlayer)
        }
    }
    
    return SetListsView_Preview()
}
