//
//  RateView.swift
//  Off The Spots
//
//  Created by David Freeman on 12/4/24.
//

import SwiftUI
import AVFoundation

struct RateView: View {
    @ObservedObject var player: AudioHelper
    
    @Binding var rateValue: Float
    
    var body: some View {
        VStack {
            Text("Playback Speed")
                .font(.subheadline)
                .padding(.bottom)
            
            HStack(spacing: 20) {
                Button(action: {
                    if(rateValue > 0.2) {
                        withAnimation {
                            rateValue -= 0.1
                        }
                        player.setRate(value: rateValue)
                    }
                }, label: {
                    Image(systemName: "tortoise.fill")
                        .font(.title2)
                        .foregroundColor(rateValue > 0.2 ? .primary : .secondary)
                        .frame(width: 20, height: 20)
                })
                
                Button(action: { player.setRate(value: 1) }, label: {
                    Text("\(String(format: "%.1f", rateValue))×")
                        .font(.title2)
                        .contentTransition(.numericText())
                        .padding(.horizontal, 4)
                })
                .buttonStyle(.plain)
                
                Button(action: {
                    if(rateValue < 2) {
                        withAnimation {
                            rateValue += 0.1
                        }
                        player.setRate(value: rateValue)
                    }
                }, label: {
                    Image(systemName: "hare.fill")
                        .font(.title2)
                        .foregroundColor(rateValue < 2 ? .primary : .secondary)
                        .frame(width: 20, height: 20)
                })
            }
        }
        .sensoryFeedback(.increase, trigger: rateValue) { oldValue, newValue in
            return newValue > oldValue
        }
        .sensoryFeedback(.decrease, trigger: rateValue) { oldValue, newValue in
            return newValue < oldValue
        }
    }
}

#Preview {
    struct RateView_Preview: View {
        @StateObject var player: AudioHelper = AudioHelper()
        
        var body: some View {
            RateView(player: player, rateValue: $player.rateValue)
                .frame(maxHeight: 50)
        }
    }
    
    return RateView_Preview()
}
