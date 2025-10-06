//
//  SetListsView.swift
//  Off The Spots
//
//  Created by David Freeman on 7/16/25.
//

import SwiftUI

struct SetListsView: View {
    var body: some View {
        NavigationStack {
            Text("Set Lists")
                .navigationTitle("Set Lists")
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        NavigationLink(destination: SettingsView(), label: {Image(systemName: "gearshape") })
                    }
                }
        }
    }
}

#Preview {
    SetListsView()
}
