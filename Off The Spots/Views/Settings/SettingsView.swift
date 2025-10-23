//
//  SettingsView.swift
//  Off The Spots
//
//  Created by David Freeman on 12/3/24.
//

import SwiftUI
import StoreKit

struct SettingsView: View {
    @Environment(\.requestReview) var requestReview
    @Environment(\.openURL) var openURL
    @State private var showMail = false
    @Binding var hideMiniPlayer: Bool

    var body: some View {
        List {
            Section {
                Button(action: {}, label: {
                    HStack {
                        Image(systemName: "creditcard")
                        VStack {
                            Text("Subscribe to Pro")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text("Set Lists, App Icons, and More!")
                                .font(.footnote)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                })
                .buttonStyle(.plain)
                
                Button(action: {}, label: {
                    HStack {
                        Image(systemName: "arrow.trianglehead.2.counterclockwise")
                        Text("Restore Purchases")
                    }
                })
                .buttonStyle(.plain)
            }
            
            Section {
                NavigationLink(destination: WhatsNewView(), label: {
                    HStack {
                        Image(systemName: "bell.badge")
                        VStack {
                            Text("What's New?")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text("Read about the latest updates")
                                .font(.footnote)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                })
                
                NavigationLink(destination: AboutView(), label: {
                    HStack {
                        Image(systemName: "info.circle")
                        VStack {
                            Text("About")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text("Learn about the people behind Off The Spots")
                                .font(.footnote)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                })
            }
            
            Section {
                Button(action: { showMail = true }, label: {
                    HStack {
                        Image(systemName: "envelope")
                        VStack {
                            Text("Send Feedback")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text("Feedback and suggestions are always welcome!")
                                .font(.footnote)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                })
                .buttonStyle(.plain)
                
                Button(action: { requestReview() }, label: {
                    HStack {
                        Image(systemName: "star")
                        VStack {
                            Text("Rate Off The Spots")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text("Rate on the App Store")
                                .font(.footnote)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                })
                .buttonStyle(.plain)
            }
            
            Section {
                Button(action: { openURL(URL(string: "https://d3.codes")!) }, label: {
                    HStack {
                        Text("Support")
                        Spacer()
                        Image(systemName: "link")
                    }
                })
                .buttonStyle(.plain)
                
                Button(action: { openURL(URL(string: "https://d3.codes")!) }, label: {
                    HStack {
                        Text("Privacy Policy")
                        Spacer()
                        Image(systemName: "link")
                    }
                })
                .buttonStyle(.plain)
            }
            
            Section("More by D3codes") {
                Button(action: { openURL(URL(string: "itms-apps://itunes.apple.com/app/id1492605892")!) }, label: {
                    HStack {
                        Image("wristPipeIcon")
                            .resizable()
                            .frame(width: 50, height: 50)
                        VStack {
                            Text("Wrist Pipe")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text("A pitch pipe for your wrist!")
                                .font(.footnote)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                })
                .buttonStyle(.plain)
            }
        }
        .sheet(isPresented: $showMail) { MailView() }
        .navigationTitle(Text("Settings"))
        .toolbar(.hidden, for: .tabBar)
        .onAppear { hideMiniPlayer = true }
    }
}

#Preview {
    struct SettingsView_Preview: View {
        @State private var hideMiniPlayer: Bool = false
        
        var body: some View {
            SettingsView(hideMiniPlayer: $hideMiniPlayer)
        }
    }
    
    return SettingsView_Preview()
}
