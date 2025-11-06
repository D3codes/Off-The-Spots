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
            
            Group {
                HStack {
                    Image("dad")
                        .resizable()
                        .frame(width: 100, height: 80)
                        .clipShape(.rect(cornerRadius: 10))
                    
                    Text("My father, Dave, for introducing me to singing.")
                }
                
                HStack {
                    Text("My daughter, Elizabeth, for sharing my love of music.")
                    
                    Image("david")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .clipShape(.rect(cornerRadius: 10))
                }
            }
            
            Divider()
            
            Group {
                HStack {
                    Image("n4n")
                        .resizable()
                        .frame(width: 120, height: 80)
                        .clipShape(.rect(cornerRadius: 10))
                    
                    Text("My first quartet, Not For Nothing, for singing with me.")
                }
                
                HStack {
                    Text("My second quartet, The Brovertones, for singing with me.")
                    
                    Image("brovertones")
                        .resizable()
                        .frame(width: 120, height: 80)
                        .clipShape(.rect(cornerRadius: 10))
                }
            }
            
            Divider()
            
            Group {
                HStack {
                    Image("bhs")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .clipShape(.rect(cornerRadius: 10))
                    
                    Text("The [Barbershop Harmony Society](https://barbershop.org) for enhancing my love of music.")
                }
            }
            
            Group {
//                Image("david")
//                    .resizable()
//                    .scaledToFit()
//                    .clipShape(.rect(cornerRadius: 10))
//                    .padding()
                
                Text("Thank you for trying Off The Spots! 💈")
                    .padding(.top)
            }
        }
        .scrollIndicators(.hidden)
        .navigationTitle("About")
        .padding(.horizontal)
        .background(backgroundGradient)
    }
}

#Preview {
    NavigationStack {
        AboutView()
    }
}
