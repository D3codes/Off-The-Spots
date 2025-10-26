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

    init(sheetMusicFile: Data, dismissSheetMusicView: @escaping () -> Void) {
        self.sheetMusicFile = sheetMusicFile
        self.dismissSheetMusicView = dismissSheetMusicView
    }
    
    var body: some View {
        NavigationStack {
            PDFUIView(pdfData: sheetMusicFile)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea(edges: .all)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(role: .cancel, action: dismissSheetMusicView)
                    }
                }
        }
        .statusBar(hidden: true)
        .onAppear {
            DispatchQueue.main.async {
                AppDelegate.orientationLock = UIInterfaceOrientationMask.allButUpsideDown
                if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let root = scene.keyWindow?.rootViewController {
                    root.setNeedsUpdateOfSupportedInterfaceOrientations()
                }
            }
        }
        .onDisappear {
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
                        dismissSheetMusicView: { presentSheetMusicViewer = false }
                    )
                    .interactiveDismissDisabled(true)
                }
            }
        }
    }
    
    return SheetMusicView_Preview()
}
