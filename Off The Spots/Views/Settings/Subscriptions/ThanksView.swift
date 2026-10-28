//
//  ThanksView.swift
//  Off The Spots
//
//  Created by David Freeman on 11/7/25.
//

import SwiftUI

struct ThanksView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                FlyingNotesView()
                
                VStack {
                    Text("Thank You!")
                        .font(.largeTitle)
                        .bold()
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer()
                    
                    Image("david")
                        .resizable()
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                        .scaledToFit()
                        .frame(maxWidth: 200, maxHeight: 200)
                    
                    VStack(spacing: 16) {
                        Text("Hi! 👋")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("My name is David and I’m the developer of Off The Spots. I hope you enjoy using the app!")
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("This is a one-person project, so your subscription directly supports my ability to keep adding new features.")
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("Thank you for your support and keep the whole world singing!")
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding()
                    .glassEffect(in: RoundedRectangle(cornerRadius: 20))
                    .padding()
                    
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(backgroundGradient)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(role: .cancel, action: { dismiss() })
                }
            }
        }
    }
}

#Preview {
    struct ThanksView_Preview: View {
        @State private var isPresented: Bool = true
        
        var body: some View {
            Button(action: { isPresented = true }) { Text("Show Sheet") }
                .sheet(isPresented: $isPresented) {
                    ThanksView()
                }
        }
    }

    return ThanksView_Preview()
}
