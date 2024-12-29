//
//  SplashScreenView.swift
//  Off The Spots
//
//  Created by Caullen Sasnett on 12/29/24.
//

import SwiftUI

struct SplashScreenView: View {
    @Binding var isSheetPresented: Bool

    var body: some View {
        VStack {
            ZStack {
                Image(systemName: "music.note")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.primary)
                    .rotationEffect(.degrees(-15))
                VStack {
                    Text("OFF THE")
                        .font(.largeTitle)
                        .fontWeight(.ultraLight)
                        .foregroundStyle(.primary)
                    Text("SPOTS")
                        .font(.system(size: 48))
                        .fontWeight(.heavy)
                        .foregroundStyle(.background)
                }
                .rotationEffect(.degrees(-28))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            
            Text("Add a song to get started")
                .font(.headline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Button(action: { isSheetPresented.toggle() }) {
                HStack {
                    Image(systemName: "plus")
                    Text("Add Song")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview {
    SplashScreenView(isSheetPresented: Binding.constant(false))
}
