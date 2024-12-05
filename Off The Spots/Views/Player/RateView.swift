//
//  RateView.swift
//  Off The Spots
//
//  Created by David Freeman on 12/4/24.
//

import SwiftUI
import AVFoundation

struct RateView: View {
    @Binding var audioPlayer: AVAudioPlayer
    @State var rateValue: Float
    
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
                            rateValue -= 0.1
                            audioPlayer.rate = rateValue
                        }
                    }, label: {
                        Image(systemName: "minus")
                            .font(.title2)
                            .foregroundColor(.primary)
                    })
                    
                    Text("\(String(format: "%.1f", rateValue))x")
                        .font(.title2)
                    
                    Button(action: {
                        if(rateValue < 2) {
                            rateValue += 0.1
                            audioPlayer.rate = rateValue
                        }
                    }, label: {
                        Image(systemName: "plus")
                            .font(.title2)
                            .foregroundColor(.primary)
                    })
                }
            }
            .padding(.bottom)
        }
        .frame(maxHeight: 50)
    }
}

#Preview {
    struct RateView_Preview: View {
        @State var audioPlayer: AVAudioPlayer = AVAudioPlayer()
        
        var body: some View {
            RateView(audioPlayer: $audioPlayer, rateValue: audioPlayer.rate)
        }
    }
    
    return RateView_Preview()
}
