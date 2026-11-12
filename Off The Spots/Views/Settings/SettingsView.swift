//
//  SettingsView.swift
//  Off The Spots
//
//  Created by David Freeman on 12/3/24.
//

import SwiftUI
import StoreKit
import UIKit

struct SettingsView: View {
    @Environment(\.otsProGroupId) var otsProGroupId
    @Environment(\.requestReview) var requestReview
    @Environment(\.openURL) var openURL
    
    @Binding var hideMiniPlayer: Bool
    
    @State private var showMail = false
    
    @State private var isPro: Bool = false
    @State private var presentThanksSheet: Bool = false

    @State private var isRestoring = false
    @State private var showRestoreResult = false
    @State private var restoreMessage: LocalizedStringKey = ""
    @State private var restoreDiagnostics: String?
    
    @State var show = false
    
    var body: some View {
        List {
            Section {
                NavigationLink(destination: SubscriptionView(), label: {
                    HStack {
                        Image(systemName: "creditcard.fill").foregroundStyle(.accent)
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
                        Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90.circle.fill").foregroundStyle(.green)
                        Text("Restore Subscription")
                        if isRestoring {
                            Spacer()
                            ProgressView()
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Capsule())
                })
                .buttonStyle(.plain)
                .disabled(isRestoring)
            }
            
            Section {
                NavigationLink(destination: AboutView(), label: {
                    HStack {
                        Image(systemName: "info.circle.fill").foregroundStyle(.gray)
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
                        Image(systemName: "envelope.fill").foregroundStyle(.primary)
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
                        Image(systemName: "star.fill").foregroundStyle(.yellow)
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
            
            Section {
                Button(action: { openURL(URL(string: "https://d3.codes/apps/offthespots/support")!) }, label: {
                    HStack {
                        Text("Support")
                        Spacer()
                        Image(systemName: "link")
                    }
                    .contentShape(Capsule())
                })
                .buttonStyle(.plain)
                
                Button(action: { openURL(URL(string: "https://d3.codes/apps/offthespots/privacypolicy")!) }, label: {
                    HStack {
                        Text("Privacy Policy")
                        Spacer()
                        Image(systemName: "link")
                    }
                    .contentShape(Capsule())
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
        .sheet(isPresented: $presentThanksSheet) { ThanksView() }
        .alert("Restore Subscription", isPresented: $showRestoreResult) {
            if let restoreDiagnostics {
                Button("Copy Diagnostics") {
                    UIPasteboard.general.string = restoreDiagnostics
                }
            }
            Button("OK", role: .cancel) {}
        } message: {
            Text(restoreMessage)
        }
        .navigationTitle(Text("Settings"))
        .toolbar(.hidden, for: .tabBar)
        .onAppear { hideMiniPlayer = true }
        .ignoresSafeArea(.keyboard)
        .scrollContentBackground(.hidden)
        .background(secondaryBackground)
        .toolbar {
            if isPro {
                if #available(iOS 27.1, *) {
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
                    .axisBehavior(.horizontalOnly)
                } else {
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
        }
        .subscriptionStatusTask(for: otsProGroupId) { taskState in
            isPro = StoreHelper.checkForActiveSubscription(in: taskState)
        }
    }

    private func restore() async {
        guard !isRestoring else { return }
        isRestoring = true
        restoreDiagnostics = nil
        defer { isRestoring = false }

        var step = StoreHelper.RestoreStep.sync
        do {
            try await AppStore.sync()
            step = .subscriptionStatus
            isPro = try await StoreHelper.refreshProEntitlement(groupID: otsProGroupId)
            restoreMessage = isPro
                ? "Your Off The Spots Pro subscription is active."
                : "No active Off The Spots Pro subscription was found for this App Store account."
        } catch StoreKitError.userCancelled {
            restoreMessage = "Restore was cancelled."
        } catch {
            restoreMessage = "Unable to check your subscription with the App Store. Please try again later."
            restoreDiagnostics = StoreHelper.restoreDiagnosticDetails(step: step, error: error)
        }
        showRestoreResult = true
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
