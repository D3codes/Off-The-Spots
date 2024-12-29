//
//  PlaybackProgressView.swift
//  Off The Spots
//
//  Created by David Freeman on 12/5/24.
//

import SwiftUI
import AVFoundation

struct PlaybackProgressView: View {
    @Binding var audioPlayer: AVAudioPlayer
    @Binding var progress: Double
    @Binding var isEditingProgress: Bool
    
    var body: some View {
        VStack {
            UISliderView(
                value: $progress,
                handleTouchDown: handleTouchDown,
                handleTouchUp: handleTouchUp,
                minValue: 0.0,
                maxValue: audioPlayer.duration,
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
                
                Text("-\(Int(audioPlayer.duration-progress + 0.5) / 60):\(String(format: "%02d", Int(audioPlayer.duration-progress + 0.5) % 60))")
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
        audioPlayer.currentTime = progress
    }
}


#Preview {
    struct PlaybackProgressView_Preview: View {
        @State var audioPlayer: AVAudioPlayer = AVAudioPlayer()
        @State var progress: Double = 0.0
        @State var isEditingProgress: Bool = false
        
        var body: some View {
            PlaybackProgressView(
                audioPlayer: $audioPlayer,
                progress: $progress,
                isEditingProgress: $isEditingProgress)
        }
    }
    
    return PlaybackProgressView_Preview()
}
