//
//  TestersView.swift
//  Off The Spots
//
//  Created by David Freeman on 11/11/25.
//

import SwiftUI

struct TestersView: View {
    var body: some View {
        VStack {
            Text("Testers")
                .font(.headline)
                .padding(.bottom, 2)
            
            Text("• Joe Barbershop")
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("• Rupert Hall")
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("• O.C. Cash")
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("• Frank Thorne")
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
        }
        .padding()
        .glassEffect(in: RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    AboutView()
}
