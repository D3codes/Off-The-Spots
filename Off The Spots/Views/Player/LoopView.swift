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
    @Binding var loopStartLocked: Bool
    @Binding var loopEnd: Double?
    @Binding var loopEndLocked: Bool
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
                    Button(action: handleLoopStartLockTap, label: {
                        Text("\(loopStartLocked ? "Unlock" : "Lock")")
                            .frame(width: 60)
                    })
                    .foregroundStyle(loopStart == nil ? .secondary : .primary)
                    .disabled(loopStart == nil)
                    .padding(.trailing)
                    
                    Button(action: handleLoopStartTap, label: {
                        ZStack {
                            Circle()
                                .tint(.clear)
                            
                            Image(systemName: "chevron.right.to.line")
                                .font(.title2)
                                .foregroundColor(loopStart != nil ? .accentColor : .primary)
                            
                            if(loopStartLocked) {
                                ZStack {
                                    Circle()
                                        .frame(width: 20, height: 20)
                                        .foregroundStyle(.ultraThinMaterial)
                                        .opacity(0.8)
                                    Image(systemName: "lock.fill")
                                        .font(.caption)
                                        .bold()
                                        .foregroundColor(.primary)
                                }
                            }
                        }
                    })
                    .disabled(loopStartLocked)
                    
                    Button(action: {
                        if isLooping {
                            player.stopLoop()
                        } else {
                            player.startLoop()
                        }
                    }, label: {
                        Image(systemName: "arrow.rectanglepath")
                            .font(.title2)
                            .foregroundColor(
                                loopStart == nil || loopEnd == nil
                                ? .secondary
                                : isLooping
                                    ? .accentColor
                                    : .primary)
                    })
                    .disabled(loopStart == nil || loopEnd == nil)
                    
                    Button(action: handleLoopEndTap, label: {
                        ZStack {
                            Circle()
                                .tint(.clear)
                            
                            Image(systemName: "chevron.left.to.line")
                                .font(.title2)
                                .foregroundColor(loopEnd != nil ? .accentColor : .primary)
                            
                            if(loopEndLocked) {
                                ZStack {
                                    Circle()
                                        .frame(width: 20, height: 20)
                                        .foregroundStyle(.ultraThinMaterial)
                                        .opacity(0.8)
                                    Image(systemName: "lock.fill")
                                        .font(.caption)
                                        .bold()
                                        .foregroundColor(.primary)
                                }
                            }
                        }
                    })
                    .disabled(loopEndLocked)
                    
                    Button(action: handleLoopEndLockTap, label: {
                        Text("\(loopEndLocked ? "Unlock" : "Lock")")
                            .frame(width: 60)
                    })
                    .foregroundStyle(loopEnd == nil ? .secondary : .primary)
                    .disabled(loopEnd == nil)
                    .padding(.leading)
                }
            }
            .padding(20)
        }
        .sensoryFeedback(.selection, trigger: loopStart)
        .sensoryFeedback(.selection, trigger: loopEnd)
        .sensoryFeedback(.selection, trigger: isLooping)
    }
    
    private func handleLoopStartTap() {
        if(loopStart == nil) {
            guard player.setLoopStart(value: player.progress) else { return }
            
            if(loopEnd != nil) {
                loopEndLocked = true
            }
        } else if(!loopStartLocked){
            player.clearLoopStart()
        }
    }
    
    private func handleLoopStartLockTap() {
        guard loopStart != nil else { return }
        
        if(loopStartLocked) {
            loopStartLocked = false
            
            if(loopEnd != nil) {
                loopEndLocked = true
            }
        } else {
            loopStartLocked = true
        }
    }

    private func handleLoopEndTap() {
        if(loopEnd == nil) {
            guard player.setLoopEnd(value: player.progress) else { return }
            
            if(loopStart != nil) {
                loopStartLocked = true
            }
        } else if(!loopEndLocked){
            player.clearLoopEnd()
        }
    }
    
    private func handleLoopEndLockTap() {
        guard loopEnd != nil else { return }
        
        if(loopEndLocked) {
            loopEndLocked = false
            
            if(loopStart != nil) {
                loopStartLocked = true
            }
        } else {
            loopEndLocked = true
        }
    }
}

#Preview {
    struct LoopView_Preview: View {
        @StateObject var player: AudioHelper = AudioHelper()
        @State var loopStartLocked: Bool = false
        @State var loopEndLocked: Bool = false
        
        var body: some View {
            LoopView(
                player: player,
                loopStart: $player.loopStart,
                loopStartLocked: $loopStartLocked,
                loopEnd: $player.loopEnd,
                loopEndLocked: $loopEndLocked,
                isLooping: $player.isLooping)
            .frame(maxHeight: 50)
        }
    }
    
    return LoopView_Preview()
}

