//
//  LoopView.swift
//  Off The Spots
//
//  Created by David Freeman on 12/29/24.
//

import SwiftUI
import AVFoundation

struct LoopView: View {
    @ObservedObject var player: AudioHelper
    
    @Binding var loopStart: Double?
    @Binding var loopEnd: Double?
    @Binding var isLooping: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.thinMaterial)
            
            VStack {
                Text("Loop Section")
                    .font(.subheadline)
                    .padding(.bottom)
                
                HStack(spacing: 20) {
                    Button(action: {
                        if loopStart == nil {
                            player.setLoopStart(value: player.progress)
                        } else {
                            player.clearLoopStart()
                        }
                    }, label: {
                        ZStack {
                            Circle()
                                .tint(.clear)
                            
                            Image(systemName: "chevron.right.to.line")
                                .font(.title2)
                                .foregroundColor(loopStart != nil ? .accentColor : .primary)
                        }
                    })
                    
                    Button(action: {
                        if isLooping {
                            player.stopLoop()
                        } else {
                            player.startLoop()
                        }
                    }, label: {
                        Image(systemName: "arrow.rectanglepath")
                            .font(.title2)
                            .foregroundColor(isLooping ? .accentColor : .primary)
                    })
                    .disabled(loopStart == nil || loopEnd == nil)
                    
                    Button(action: {
                        if loopEnd == nil {
                            player.setLoopEnd(value: player.progress)
                        } else {
                            player.clearLoopEnd()
                        }
                    }, label: {
                        ZStack {
                            Circle()
                                .tint(.clear)
                            
                            Image(systemName: "chevron.left.to.line")
                                .font(.title2)
                                .foregroundColor(loopEnd != nil ? .accentColor : .primary)
                        }
                    })
                }
            }
            .padding(20)
        }
        .sensoryFeedback(.selection, trigger: loopStart)
        .sensoryFeedback(.selection, trigger: loopEnd)
        .sensoryFeedback(.selection, trigger: isLooping)
    }
}

#Preview {
    struct LoopView_Preview: View {
        @StateObject var player: AudioHelper = AudioHelper()
        
        var body: some View {
            LoopView(
                player: player,
                loopStart: $player.loopStart,
                loopEnd: $player.loopEnd,
                isLooping: $player.isLooping)
        }
    }
    
    return LoopView_Preview()
}

