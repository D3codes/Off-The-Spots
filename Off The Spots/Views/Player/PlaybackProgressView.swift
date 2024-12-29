//
//  PlaybackProgressView.swift
//  Off The Spots
//
//  Created by David Freeman on 12/5/24.
//

import SwiftUI
import AVFoundation

struct PlaybackProgressView: View {
    @ObservedObject var player: AudioHelper
    
    @Binding var duration: Double
    @Binding var progress: Double
    @Binding var isEditingProgress: Bool
    
    var body: some View {
        VStack {
            UISliderView(
                value: $progress,
                handleTouchDown: handleTouchDown,
                handleTouchUp: handleTouchUp,
                minValue: 0.0,
                maxValue: duration,
                thumbColor: .clear,
                minTrackColor: UIColor(.primary),
                maxTrackColor: UIColor(.secondary)
            )
            .mask(
                Capsule()
                    .frame(maxWidth: .infinity, maxHeight: 4)
                    .padding(.horizontal, 12)
                    .offset(y: 1)
            )
            .scaleEffect(x: 1, y: isEditingProgress ? 2 : 1)
            
            HStack {
                Text("\(Int(progress + 0.5) / 60):\(String(format: "%02d", Int(progress + 0.5) % 60))")
                
                Spacer()
                
                Text("-\(Int(duration-progress + 0.5) / 60):\(String(format: "%02d", Int(duration-progress + 0.5) % 60))")
            }
        }
    }
    
    private func handleTouchDown() {
        withAnimation {
            isEditingProgress = true
        }
    }
    
    private func handleTouchUp() {
        withAnimation {
            isEditingProgress = false
        }
        
        player.setCurrentTime(value: progress)
    }
}


#Preview {
    struct PlaybackProgressView_Preview: View {
        @StateObject var player: AudioHelper = AudioHelper()
        @State var progress: Double = 0.0
        @State var isEditingProgress: Bool = false
        
        var body: some View {
            PlaybackProgressView(
                player: player,
                duration: $player.duration,
                progress: $player.progress,
                isEditingProgress: $isEditingProgress)
        }
    }
    
    return PlaybackProgressView_Preview()
}
