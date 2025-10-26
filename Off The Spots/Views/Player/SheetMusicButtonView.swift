//
//  SheetMusicButtonView.swift
//  Off The Spots
//
//  Created by David Freeman on 10/26/25.
//

import SwiftUI

struct SheetMusicButtonView: View {
    var sheetMusicFile: Data?
    
    @State private var presentSheetMusic: Bool = false
    
    var body: some View {
        Button(action: { presentSheetMusic = true }) {
            Image(systemName: "music.pages.fill")
            Text("Sheet Music")
        }
        .tint(.primary)
        .disabled(sheetMusicFile == nil)
        .fullScreenCover(isPresented: $presentSheetMusic) {
            SheetMusicView(sheetMusicFile: sheetMusicFile!, dismissSheetMusicView: { presentSheetMusic = false })
        }
    }
}

#Preview {
    SheetMusicButtonView()
}
