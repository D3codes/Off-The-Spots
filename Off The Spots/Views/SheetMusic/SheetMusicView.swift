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
