//
//  LoopView.swift
//  Off The Spots
//
//  Created by David Freeman on 12/29/24.
//

import SwiftUI

struct LoopView: View {
    @ObservedObject var player: AudioHelper

    var body: some View {
        VStack(spacing: 4) {
            Text("Loop Section")
                .font(.subheadline)

            HStack(spacing: 28) {
                Button {
                    if player.loopStart == nil {
                        _ = player.setLoopStart(value: player.playbackProgress.value)
                    } else {
                        player.clearLoopStart()
                    }
                } label: {
                    controlIcon("chevron.right.to.line", active: player.loopStart != nil)
                }
                .accessibilityLabel(player.loopStart == nil ? "Set Loop Start" : "Clear Loop Start")
                .disabled(player.duration <= 0)

                Button {
                    if player.isLooping {
                        player.stopLoop()
                    } else {
                        player.startLoop()
                    }
                } label: {
                    controlIcon("arrow.rectanglepath", active: player.isLooping)
                }
                .accessibilityLabel(player.isLooping ? "Stop Loop" : "Start Loop")
                .disabled(player.loopStart == nil || player.loopEnd == nil)

                Button {
                    if player.loopEnd == nil {
                        _ = player.setLoopEnd(value: player.playbackProgress.value)
                    } else {
                        player.clearLoopEnd()
                    }
                } label: {
                    controlIcon("chevron.left.to.line", active: player.loopEnd != nil)
                }
                .accessibilityLabel(player.loopEnd == nil ? "Set Loop End" : "Clear Loop End")
                .disabled(player.duration <= 0)
            }
            .buttonStyle(.borderless)
        }
        .sensoryFeedback(.selection, trigger: player.loopStart)
        .sensoryFeedback(.selection, trigger: player.loopEnd)
        .sensoryFeedback(.selection, trigger: player.isLooping)
    }

    private func controlIcon(_ symbol: String, active: Bool) -> some View {
        Image(systemName: symbol)
            .font(.title2)
            .foregroundStyle(active ? Color.accentColor : Color.primary)
            .frame(width: 44, height: 44)
            .contentShape(Rectangle())
    }
}

#Preview {
    @Previewable @StateObject var player = AudioHelper()
    LoopView(player: player)
        .onAppear { player.duration = 120 }
}
