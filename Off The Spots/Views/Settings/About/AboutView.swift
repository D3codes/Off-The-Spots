//
//  AboutView.swift
//  Off The Spots
//
//  Created by David Freeman on 7/16/25.
//

import SwiftUI

struct AboutView: View {
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    
    var body: some View {
        ScrollView {
            Group {
                Image("icon")
                    .resizable()
                    .frame(width: 100, height: 100)
                
                Text("Off The Spots")
                    .font(.title)
                
                Text("\(appVersion != nil ? " \(appVersion!)" : "")")
                    .font(.subheadline)
                    .padding(.bottom)
            }
            
            Group {
                Text("Off The Spots was created in Kansas City by [David Freeman](https://d3.codes/about).")
                
                Text("Though it was written by me, Off The Spots wouldn't be possible without the influence of the following people:")
            }
            .padding(.bottom)
            .padding(.horizontal)
            
            Group {
                HStack {
                    Image("dad")
                        .resizable()
                        .frame(width: 100, height: 80)
                        .clipShape(.rect(cornerRadius: 10))
                    
                    Text("My father, Dave, for introducing me to singing and encouraging my passions.")
                }
                
                HStack {
                    Text("My daughter, Elizabeth, for sharing my love of music and being a wonderful distraction when I needed one.")
                    
                    Image("david")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .clipShape(.rect(cornerRadius: 10))
                }
            }
            .padding(.horizontal)
            
            Divider()
                .padding(.horizontal)
            
            Group {
                Text("Every person I've shared a chord with. Whether on a stage, at a convention, or just in a stairwell.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                CarouselView(images: [
                    Image("n4n"),
                    Image("centralStandard"),
                    Image("brovertones"),
                    Image("n4nHarmonyExplosion"),
                    Image("brosAward"),
                    Image("midwinter"),
                    Image("zombieProm"),
                    Image("n4nSleeping"),
                    Image("choraliers"),
                    Image("singingValentine")
                ])
                .frame(maxHeight: 250)
            }
            
            Divider()
                .padding(.horizontal)
            
            Group {
                HStack {
                    Image("bhs")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .clipShape(.rect(cornerRadius: 10))
                    
                    Text("The [Barbershop Harmony Society](https://barbershop.org) for giving me a community of talented musicians and great friends.")
                }
            }
            .padding(.horizontal)
            
            Divider()
                .padding(.horizontal)
            
            Group {
                HStack {
                    TestersView()
                    .containerRelativeFrame(.horizontal) { length, axis in
                        length * 0.45
                    }
                    
                    PackagesView()
                    .containerRelativeFrame(.horizontal) { length, axis in
                        length * 0.45
                    }
                }
            }
            .padding(.horizontal)
            
            Text("Thank you for trying Off The Spots! 💈")
                .padding(.top)
        }
        .scrollIndicators(.hidden)
        .navigationTitle("About")
        .background(backgroundGradient)
    }
}

#Preview {
    NavigationStack {
        AboutView()
    }
}
