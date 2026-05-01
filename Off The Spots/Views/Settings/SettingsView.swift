//
//  SettingsView.swift
//  Off The Spots
//
//  Created by David Freeman on 12/3/24.
//

import SwiftUI
import StoreKit

struct SettingsView: View {
    @Environment(\.otsProGroupId) var otsProGroupId
    @Environment(\.requestReview) var requestReview
    @Environment(\.openURL) var openURL
    
    @Binding var hideMiniPlayer: Bool
    
    @State private var showMail = false
    
    @State private var isPro: Bool = false
    @State private var presentThanksSheet: Bool = false

    func restore() async -> Bool {
        return ((try? await AppStore.sync()) != nil)
    }
    
    var body: some View {
        List {
            Section {
                NavigationLink(destination: SubscriptionView(presentThanksSheet: $presentThanksSheet), label: {
                    HStack {
                        Image(systemName: "creditcard")
                        VStack {
                            Text("Subscribe to Pro")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text("Unlimited Songs and Tracks, Set Lists, and More!")
                                .font(.footnote)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                })
                
                Button(action: { Task { await restore() } }, label: {
                    HStack {
                        Image(systemName: "arrow.trianglehead.2.counterclockwise")
                        Text("Restore Purchases")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Capsule())
                })
                .buttonStyle(.plain)
            }
            .listRowBackground(listItemBackground)
            
            Section {
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
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Capsule())
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
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Capsule())
                })
                .buttonStyle(.plain)
            }
            .listRowBackground(listItemBackground)
            
            Section {
                Button(action: { openURL(URL(string: "https://d3.codes")!) }, label: {
                    HStack {
                        Text("Support")
                        Spacer()
                        Image(systemName: "link")
                    }
                    .contentShape(Capsule())
                })
                .buttonStyle(.plain)
                
                Button(action: { openURL(URL(string: "https://d3.codes")!) }, label: {
                    HStack {
                        Text("Privacy Policy")
                        Spacer()
                        Image(systemName: "link")
                    }
                    .contentShape(Capsule())
                })
                .buttonStyle(.plain)
            }
            .listRowBackground(listItemBackground)
            
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
            .listRowBackground(listItemBackground)
        }
        .sheet(isPresented: $showMail) { MailView() }
        .sheet(isPresented: $presentThanksSheet) { ThanksView() }
        .navigationTitle(Text("Settings"))
        .toolbar(.hidden, for: .tabBar)
        .onAppear { hideMiniPlayer = true }
        .scrollContentBackground(.hidden)
        .ignoresSafeArea(.keyboard)
        .background(backgroundGradient)
        .toolbar {
            if isPro {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { presentThanksSheet = true }) {
                        Text("Pro")
                            .font(.title)
                            .bold()
                            .gradientForeground(colors: [.teal, Color.otsBlue])
                    }
                    .buttonStyle(.glassProminent)
                    .tint(.primary)
                }
            }
        }
        .subscriptionStatusTask(for: otsProGroupId) { taskState in
            isPro = StoreHelper.checkForActiveSubscription(in: taskState)
        }
    }
}

#Preview {
    struct SettingsView_Preview: View {
        @State private var hideMiniPlayer: Bool = false
        
        var body: some View {
            NavigationStack {
                SettingsView(hideMiniPlayer: $hideMiniPlayer)
            }
        }
    }
    
    return SettingsView_Preview()
}
