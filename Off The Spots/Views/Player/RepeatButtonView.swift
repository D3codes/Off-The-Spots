//
//  RepeatButtonView.swift
//  Off The Spots
//
//  Created by David Freeman on 11/2/26.
//

import SwiftUI

struct RepeatButtonView: View {
    
    var body: some View {
        Button(action: {
            
        }, label: {
            Image(systemName: "repeat")
                .foregroundStyle(.primary)
        })
        .buttonStyle(.plain)
    }
}

#Preview {
    RepeatButtonView()
}
