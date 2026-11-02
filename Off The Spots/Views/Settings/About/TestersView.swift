//
//  TestersView.swift
//  Off The Spots
//
//  Created by David Freeman on 11/11/25.
//

import SwiftUI

struct TestersView: View {
    
    let testers: [String] = [
        "Rich Kihlken",
        "Ryan Fuller",
        "Brittany Sloan",
        "Steve Fuller",
        "Mike Olson",
        "Debbie Dodge",
        "Zak Stratton",
        "Larry Dodge"
    ]
    
    @State private var sortedTesters: [String] = []
    
    var body: some View {
        VStack {
            Text("Testers")
                .font(.headline)
                .padding(.bottom, 2)
            
            ForEach(sortedTesters, id: \.self) { tester in
                Text("• \(tester)")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Spacer()
        }
        .padding()
        .glassEffect(in: RoundedRectangle(cornerRadius: 10))
        .onAppear {
            sortedTesters = testers.sorted { (name1, name2) -> Bool in
                let components1 = name1.split(separator: " ")
                let components2 = name2.split(separator: " ")
                
                // Safely extract last and first names, defaulting to the original string if no space exists
                let lastName1 = components1.last ?? ""
                let firstName1 = components1.first ?? ""
                
                let lastName2 = components2.last ?? ""
                let firstName2 = components2.first ?? ""
                
                // Swift compares tuples element by element: first by last name, then by first name
                return (lastName1, firstName1) < (lastName2, firstName2)
            }
        }
    }
}

#Preview {
    AboutView()
}
