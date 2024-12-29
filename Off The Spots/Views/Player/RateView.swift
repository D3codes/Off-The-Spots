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
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.thinMaterial)
            
            VStack {
                Text("Playback Speed")
                    .font(.subheadline)
                    .padding(.vertical)
                
                HStack(spacing: 25) {
                    Button(action: {
                        if(rateValue > 0.2) {
                            withAnimation {
                                rateValue -= 0.1
                            }
                            player.setRate(value: rateValue)
                        }
                    }, label: {
                        Image(systemName: "minus")
                            .font(.title)
                            .foregroundColor(.primary)
                    })
                    
                    Text("\(String(format: "%.1f", rateValue))x")
                        .font(.title)
                        .contentTransition(.numericText())
                    
                    Button(action: {
                        if(rateValue < 2) {
                            withAnimation {
                                rateValue += 0.1
                            }
                            player.setRate(value: rateValue)
                        }
                    }, label: {
                        Image(systemName: "plus")
                            .font(.title)
                            .foregroundColor(.primary)
                    })
                }
            }
            .padding(.bottom)
        }
        .frame(maxHeight: 50)
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
        }
    }
    
    return RateView_Preview()
}
