//
//  RandomSpotView.swift
//  Off The Spots
//
//  Created by David Freeman on 10/28/26.
//

import SwiftUI

struct RandomSpotView: View {
    var body: some View {
        let appearance = SpotContent.random()

        Image(appearance.pose.rawValue)
            .resizable()
            .scaledToFit()
            .frame(width: 300)
            .padding(.bottom, 0)

        Text(appearance.quote)
            .font(.custom(SpotContent.quoteFontName, size: 20))
            .multilineTextAlignment(.center)
            .padding(.top, 0)
    }
}

#Preview {
    struct RandomSpotView_Preview: View {
        @State var reload: Bool = true
        
        var body: some View {
            if reload {
                RandomSpotView()
            } else {
                RandomSpotView()
            }
            
            Button("Reload") { reload.toggle() }
        }
    }
    
    return RandomSpotView_Preview()
}
