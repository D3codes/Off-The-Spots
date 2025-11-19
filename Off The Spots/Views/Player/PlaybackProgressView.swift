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

    @Binding var loopStart: Double?
    @Binding var loopStartLocked: Bool
    @Binding var loopEnd: Double?
    @Binding var loopEndLocked: Bool
    
    let loopStartImage = UIImage(named: "loopBegin")!.withTintColor(UIColor(.accentColor))
    let loopEndImage = UIImage(named: "loopEnd")!.withTintColor(UIColor(.accentColor))
    
    var body: some View {
        VStack {
            UISliderView(
                value: $progress,
                handleTouchDown: handleTouchDown,
                handleTouchUp: handleTouchUp,
                minValue: 0.0,
                maxValue: duration,
                thumbColor: .clear,
                minTrackColor: .primary,
                maxTrackColor: .secondary
            )
            .mask(
                Capsule()
                    .frame(maxWidth: .infinity, maxHeight: 4)
                    .padding(.horizontal, 12)
                    .offset(y: 1)
            )
            .scaleEffect(x: 1, y: isEditingProgress ? 2 : 1)
            .overlay(
                ZStack {
                    if loopStart != nil {
                        UISliderView(
                            value: Binding<Double>(get: {
                                return loopStart ?? 0.0
                            }, set: {
                                loopStart = $0
                            }),
                            minValue: 0.0,
                            maxValue: duration,
                            thumbImage: loopStartImage,
                            thumbColor: .primary,
                            minTrackColor: .clear,
                            maxTrackColor: .clear
                        )
                        .allowsHitTesting(!loopStartLocked)
                    }
                    
                    if loopEnd != nil {
                        UISliderView(
                            value: Binding<Double>(get: {
                                return loopEnd ?? 0.0
                            }, set: {
                                loopEnd = $0
                            }),
                            minValue: 0.0,
                            maxValue: duration,
                            thumbImage: loopEndImage,
                            thumbColor: .primary,
                            minTrackColor: .clear,
                            maxTrackColor: .clear
                        )
                        .allowsHitTesting(!loopEndLocked)
                    }
                }
            )
            
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
        
        let seekFrame = AVAudioFramePosition(progress * player.audioSampleRate)
        player.setCurrentTime(value: seekFrame)
    }
}


#Preview {
    struct PlaybackProgressView_Preview: View {
        @StateObject var player: AudioHelper = AudioHelper()
        @State var progress: Double = 0.0
        @State var isEditingProgress: Bool = false
        @State var loopStart: Double? = 0.0
        @State var loopStartLocked: Bool = true
        @State var loopEnd: Double? = nil
        @State var loopEndLocked: Bool = false
        
        var body: some View {
            PlaybackProgressView(
                player: player,
                duration: $player.duration,
                progress: $player.progress,
                isEditingProgress: $isEditingProgress,
                loopStart: $loopStart,
                loopStartLocked: $loopStartLocked,
                loopEnd: $loopEnd,
                loopEndLocked: $loopEndLocked)
        }
    }
    
    return PlaybackProgressView_Preview()
}
