//
//  SheetMusicView.swift
//  Off The Spots
//
//  Created by David Freeman on 10/24/25.
//

import SwiftUI

struct SheetMusicView: View {
    @State var sheetMusicFile: Data
    @State var dismissSheetMusicView: () -> Void
    
    var body: some View {
        ZStack {
            PDFUIView(pdfData: sheetMusicFile)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            VStack {
                HStack {
                    Button(role: .cancel, action: dismissSheetMusicView, label: {
                        Image(systemName: "xmark")
                            .frame(width: 20, height: 30)
                            .font(.title2)
                    })
                    .buttonStyle(.glass)
                    .padding()
                    
                    Spacer()
                }
                
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(edges: .all)
        .statusBar(hidden: true)
    }
}

//#Preview {
//    struct SheetMusicView_Preview: View {
//        
//        var body: some View {
//            SheetMusicView()
//        }
//    }
//    
//    return SheetMusicView_Preview()
//}
