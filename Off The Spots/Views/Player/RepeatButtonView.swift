//
//  RepeatButtonView.swift
//  Off The Spots
//
//  Created by David Freeman on 11/2/26.
//

import SwiftUI

struct RepeatButtonView: View {
    @ObservedObject var player: AudioHelper
    
    var body: some View {
        Button(action: {
            player.incrementRepeat()
        }, label: {
            if player.repeatAll {
                Image(systemName: "repeat")
                    .font(.title2)
                    .foregroundStyle(.accent)
            } else if player.repeatOne {
                Image(systemName: "repeat.1")
                    .font(.title2)
                    .foregroundStyle(.accent)
            } else {
                Image(systemName: "repeat")
                    .font(.title2)
                    .foregroundStyle(.primary)
            }
        })
        .buttonStyle(.plain)
    }
}

#Preview {
    struct RepeatButtonView_Preview: View {
        @StateObject var player: AudioHelper = AudioHelper()
        
        var body: some View {
            RepeatButtonView(player: player)
        }
    }
    
    return RepeatButtonView_Preview()
}
