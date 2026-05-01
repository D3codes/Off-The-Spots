//
//  SheetMusicListSectionView.swift
//  Off The Spots
//
//  Created by David Freeman on 10/24/25.
//

import SwiftUI

struct SheetMusicListSectionView: View {
    @Binding var sheetMusicDraft: SheetMusicDraft?
    var isPro: Bool
    @Binding var presentSubscription: Bool
    
    @State private var presentSheetMusicFileImporter: Bool = false
    @State private var presentSheetMusicViewer: Bool = false
    @State private var importErrorMessage: String?
    
    var body: some View {
        Section {
            ForEach(0...0, id: \.self) { _ in
                if let sheetMusicDraft {
                    Button(action: { presentSheetMusicViewer = true }) {
                        Text(sheetMusicDraft.name)
                    }
                    .buttonStyle(.plain)
                    .fullScreenCover(isPresented: $presentSheetMusicViewer) {
                        SheetMusicView(
                            sheetMusicFile: sheetMusicDraft.file!,
                            dismissSheetMusicView: { presentSheetMusicViewer = false }
                        )
                        .interactiveDismissDisabled(true)
                    }
                }
            }
            .onDelete(perform: deleteSheetMusic)
            .scrollContentBackground(.hidden)
            .listSectionSpacing(.compact)
//            .listRowBackground(listItemBackground)
        } header: {
            HStack {
                Image(systemName: "music.pages.fill")
                    .font(.subheadline)
                    .foregroundStyle(.accent)
                Text("Sheet Music")
                    .font(.subheadline)
                
                Spacer()
                
                if sheetMusicDraft == nil {
                    Button(action: {
                        if isPro {
                            presentSheetMusicFileImporter = true
                        } else {
                            presentSubscription = true
                        }
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .foregroundStyle(.foreground)
                            .frame(width: 10, height: 20)
                    }
                    .font(.subheadline)
                    .buttonStyle(.bordered)
                }
            }
        }
        .fileImporter(
            isPresented: $presentSheetMusicFileImporter,
            allowedContentTypes: [.pdf],
            allowsMultipleSelection: false,
            onCompletion: { results in
                switch results {
                case .success(let fileUrls):
                    // gain access to the directory
                    let gotAccess = fileUrls[0].startAccessingSecurityScopedResource()
                    if(!gotAccess) {
                        return
                    }
                    
                    // access the directory URL
                    addSheetMusic(fileUrl: fileUrls[0])
                    
                    // release access
                    fileUrls[0].stopAccessingSecurityScopedResource()
                    
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
        )
        .alert("Sheet Music Not Imported", isPresented: Binding(
            get: { importErrorMessage != nil },
            set: { if !$0 { importErrorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(importErrorMessage ?? "")
        }
    }
    
    func addSheetMusic(fileUrl: URL) {
        do {
            let fileSize = try fileUrl.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
            guard fileSize <= OffTheSpotsPersistence.maximumCloudKitAssetSize else {
                importErrorMessage = "This PDF is too large to sync with iCloud. Choose a file smaller than 249 MB."
                return
            }

            let file: Data = try Data(contentsOf: fileUrl)
            sheetMusicDraft = SheetMusicDraft(name: fileUrl.deletingPathExtension().lastPathComponent, file: file)
        } catch {
            importErrorMessage = "The selected sheet music could not be imported."
        }
    }
    
    private func deleteSheetMusic(offsets: IndexSet) {
        withAnimation {
            sheetMusicDraft = nil
        }
    }
}

#Preview {
    struct SheetMusicListView_Preview: View {
        @State private var sheetMusicDraft: SheetMusicDraft?
        
        var body: some View {
            List {
                SheetMusicListSectionView(sheetMusicDraft: $sheetMusicDraft, isPro: false, presentSubscription: .constant(false))
            }
        }
    }
    
    return SheetMusicListView_Preview()
}
