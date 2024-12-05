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
    
    var body: some View {
        UISliderView(
            value: $audioPlayer.currentTime,
            minValue: 0.0,
            maxValue: audioPlayer.duration,
            thumbColor: .clear,
            minTrackColor: .blue,
            maxTrackColor: .clear
        )
    }
}


#Preview {
    struct PlaybackProgressView_Preview: View {
        @State var audioPlayer: AVAudioPlayer = AVAudioPlayer()
        
        var body: some View {
            PlaybackProgressView(audioPlayer: $audioPlayer)
        }
    }
    
    return PlaybackProgressView_Preview()
}
