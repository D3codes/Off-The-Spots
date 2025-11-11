//
//  SheetMusicListSectionView.swift
//  Off The Spots
//
//  Created by David Freeman on 10/24/25.
//

import SwiftUI

struct SheetMusicListSectionView: View {
    @State var song: Song
    @State var isPro: Bool
    @Binding var presentSubscription: Bool
    
    @State private var presentSheetMusicFileImporter: Bool = false
    @State private var presentSheetMusicViewer: Bool = false
    
    var body: some View {
        Section {
            ForEach(0...0, id: \.self) { _ in
                if song.sheetMusic != nil {
                    Button(action: { presentSheetMusicViewer = true }) {
                        Text(song.sheetMusic!.name)
                    }
                    .buttonStyle(.plain)
                    .fullScreenCover(isPresented: $presentSheetMusicViewer) {
                        SheetMusicView(
                            sheetMusicFile: song.sheetMusic!.file!,
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
                
                if song.sheetMusic == nil {
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
    }
    
    func addSheetMusic(fileUrl: URL) {
        do {
            let file: Data = try Data(contentsOf: fileUrl)
            song.sheetMusic = SheetMusic(name: fileUrl.deletingPathExtension().lastPathComponent, file: file)
        } catch {
            
        }
    }
    
    private func deleteSheetMusic(offsets: IndexSet) {
        withAnimation {
            song.sheetMusic = nil
        }
    }
}

#Preview {
    struct SheetMusicListView_Preview: View {
        @State private var song: Song = Song(name: "Test Song", tracks: [], selectedTrack: Track(name: "Track 1"))
        
        var body: some View {
            List {
                SheetMusicListSectionView(song: song, isPro: false, presentSubscription: .constant(false))
            }
        }
    }
    
    return SheetMusicListView_Preview()
}
