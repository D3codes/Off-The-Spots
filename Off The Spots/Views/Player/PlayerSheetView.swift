//
//  PlayerSheetView.swift
//  Off The Spots
//
//  Created by David Freeman on 6/11/25.
//

import SwiftUI
import Combine

struct PlayerSheetView: View {
    @Binding var selectedSong: Song?
    @ObservedObject var player: AudioHelper
    @Binding var isEditingProgress: Bool
    @State var currentDetent: PresentationDetent = .large
    
    @Namespace private var sheetNS
    
    var body: some View {
        let minSheetHeight: CGFloat = 80
        let maxSheetHeight: CGFloat = 800
        
        GeometryReader { proxy in
            let sheetHeight = proxy.size.height
            let sheetProgress = min(max((sheetHeight - minSheetHeight) / (maxSheetHeight - minSheetHeight), 0), 1)
            Group {
//                if sheetProgress < 0.15 {
//                    if selectedSong != nil {
//                        BottomBarView(
//                            song: selectedSong!,
//                            player: player,
//                            namespace: sheetNS,
//                            sheetProgress: 1 - sheetProgress
//                        )
//                    }
//                } else {
//                    ExpandedSheetView(
//                        song: Binding($selectedSong)!,
//                        isEditingProgress: $isEditingProgress,
//                        player: player,
//                        namespace: sheetNS,
//                        sheetProgress: sheetProgress
//                    )
//                }
            }
            .animation(.spring(), value: sheetProgress)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .presentationDetents([.large], selection: $currentDetent)
        .presentationBackgroundInteraction(.enabled(upThrough: .large))
//        .presentationDragIndicator(currentDetent == .large ? .visible : .hidden)
        .presentationDragIndicator(.visible)
//        .interactiveDismissDisabled(true)
//        .onTapGesture {
//            if currentDetent == .height(minSheetHeight) {
//                currentDetent = .large
//            }
//        }
    }
}

#Preview {
    struct PlayerSheetView_Preview: View {
        @State private var song: Song? = Song(
            id: UUID(),
            name: "Blue Skies",
            tracks: [Track(name: "Bass Left")],
            selectedTrack: Track(name: "Bass Left")
        )
        
        @StateObject var player: AudioHelper = AudioHelper()
        
        @State private var isEditingProgress: Bool = false
        @State private var currentDetent: PresentationDetent = .large
        
        @State private var isPresented: Bool = true
        
        var body: some View {
            Text("HI")
                .sheet(isPresented: $isPresented) {
                    PlayerSheetView(
                        selectedSong: $song,
                        player: player,
                        isEditingProgress: $isEditingProgress)
                }
        }
    }
    
    return PlayerSheetView_Preview()
}
