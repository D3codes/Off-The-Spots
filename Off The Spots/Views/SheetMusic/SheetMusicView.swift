//
//  SheetMusicView.swift
//  Off The Spots
//
//  Created by David Freeman on 10/24/25.
//

import SwiftUI

struct SheetMusicView: View {
    let sheetMusicFile: Data
    let dismissSheetMusicView: () -> Void
    
    let player: AudioHelper?

    init(sheetMusicFile: Data, dismissSheetMusicView: @escaping () -> Void, player: AudioHelper? = nil) {
        self.sheetMusicFile = sheetMusicFile
        self.dismissSheetMusicView = dismissSheetMusicView
        self.player = player
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                PDFUIView(pdfData: sheetMusicFile)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea(edges: .all)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button(role: .cancel, action: dismissSheetMusicView)
                        }
                    }
                
                if player != nil {
                    Circle().opacity(0)
                        .toolbar {
                            ToolbarItemGroup(placement: .topBarTrailing) {
                                    Button(
                                        action: { player!.skip(seconds: -15) },
                                        label: { Image(systemName: "15.arrow.trianglehead.counterclockwise") }
                                    )
                                
                                    Button(action: {
                                        if(player!.isPlaying) {
                                            player!.pause()
                                        } else {
                                            player!.play()
                                        }
                                    }, label: {
                                        if(player!.isPlaying) {
                                            Image(systemName: "pause.fill")
                                        } else {
                                            Image(systemName: "play.fill")
                                        }
                                    })
                                
                                    Button(
                                        action: { player!.skip(seconds: 15) },
                                        label: { Image(systemName: "15.arrow.trianglehead.clockwise") }
                                    )
                            }
                        }
                }
            }
        }
        .interactiveDismissDisabled(true)
        .statusBar(hidden: true)
        .onAppear {
            player?.publishProgressChanges = false
            
            DispatchQueue.main.async {
                AppDelegate.orientationLock = UIInterfaceOrientationMask.allButUpsideDown
                if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let root = scene.keyWindow?.rootViewController {
                    root.setNeedsUpdateOfSupportedInterfaceOrientations()
                }
            }
        }
        .onDisappear {
            player?.publishProgressChanges = true
            
            DispatchQueue.main.async {
                AppDelegate.orientationLock = UIInterfaceOrientationMask.portrait
                UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
                if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let root = scene.keyWindow?.rootViewController {
                    root.setNeedsUpdateOfSupportedInterfaceOrientations()
                }
            }
        }
    }
}

#Preview {
    struct SheetMusicView_Preview: View {
        @State private var presentSheetMusicViewer: Bool = false
        @State private var sheetMusicData: Data?
        
        let player: AudioHelper = AudioHelper()
        
        var body: some View {
            if sheetMusicData == nil {
                ProgressView()
                    .onAppear {
                        do {
                            try sheetMusicData = Data(contentsOf: Bundle.main.url(forResource: "TestSheetMusic", withExtension: "pdf")!)
                        } catch { }
                    }
            } else {
                Button(action: { presentSheetMusicViewer = true }) {
                    Text("Show Sheet Music")
                }
                .buttonStyle(.glass)
                .fullScreenCover(isPresented: $presentSheetMusicViewer) {
                    SheetMusicView(
                        sheetMusicFile: sheetMusicData!,
                        dismissSheetMusicView: { presentSheetMusicViewer = false },
                        player: player
                    )
                }
            }
        }
    }
    
    return SheetMusicView_Preview()
}
