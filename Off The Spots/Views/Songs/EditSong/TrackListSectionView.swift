//
//  TrackListSectionView.swift
//  Off The Spots
//
//  Created by David Freeman on 10/24/25.
//

import SwiftUI

struct TrackListSectionView: View {
    @Binding var trackDrafts: [TrackDraft]
    var isPro: Bool
    @Binding var presentSubscription: Bool
    
    @State private var presentTrackFileImporter: Bool = false
    @State private var importErrorMessage: String?
    
    var body: some View {
        Section {
            ForEach($trackDrafts) { $trackDraft in
                TextField("", text: $trackDraft.name)
            }
            .onDelete(perform: deleteTracks)
            .if(isPro) { view in
                view.onMove(perform: moveTracks)
            }
            .scrollContentBackground(.hidden)
            .listSectionSpacing(.compact)
//            .listRowBackground(listItemBackground)
        } header: {
            HStack {
                Image(systemName: "music.note.square.stack.fill")
                    .font(.subheadline)
                    .foregroundStyle(.accent)
                Text("Tracks")
                    .font(.subheadline)
                
                Spacer()
                
                Button(action: {
                    if isPro || trackDrafts.count < 2 {
                        presentTrackFileImporter = true
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
        } footer: {
            if trackDrafts.isEmpty {
                Text("No Tracks")
                    .foregroundStyle(.secondary)
                    .font(.title3)
                    .frame(maxWidth: .infinity)
                    .padding(.top)
            }
        }
        .fileImporter(
            isPresented: $presentTrackFileImporter,
            allowedContentTypes: [
                .mp3,
                .aiff,
                .wav,
                .midi
            ],
            allowsMultipleSelection: true,
            onCompletion: { results in
                switch results {
                case .success(let fileUrls):
                    
                    fileUrls.forEach { file in
                        if isPro || trackDrafts.count < 2 {
                            
                            // gain access to the directory
                            let gotAccess = file.startAccessingSecurityScopedResource()
                            if gotAccess {
                                // access the directory URL
                                addTrack(fileUrl: file)
                                
                                // release access
                                file.stopAccessingSecurityScopedResource()
                            }
                        }
                    }
                    
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
        )
        .alert("Track Not Imported", isPresented: Binding(
            get: { importErrorMessage != nil },
            set: { if !$0 { importErrorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(importErrorMessage ?? "")
        }
    }
    
    func addTrack(fileUrl: URL) {
        do {
            let fileSize = try fileUrl.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
            guard fileSize <= OffTheSpotsPersistence.maximumCloudKitAssetSize else {
                importErrorMessage = "This file is too large to sync with iCloud. Choose a file smaller than 249 MB."
                return
            }

            let file: Data = try Data(contentsOf: fileUrl)
            let track = TrackDraft(name: fileUrl.deletingPathExtension().lastPathComponent, file: file)
            trackDrafts.append(track)
        } catch {
            importErrorMessage = "The selected track could not be imported."
        }
    }
    
    private func deleteTracks(offsets: IndexSet) {
        withAnimation {
            trackDrafts.remove(atOffsets: offsets)
        }
    }

    private func moveTracks(offsets: IndexSet, destination: Int) {
        withAnimation {
            trackDrafts.move(fromOffsets: offsets, toOffset: destination)
        }
    }
}

#Preview {
    struct TrackListView_Preview: View {
        @State private var trackDrafts: [TrackDraft] = []
        
        var body: some View {
            List {
                TrackListSectionView(trackDrafts: $trackDrafts, isPro: false, presentSubscription: .constant(false))
            }
        }
    }
    
    return TrackListView_Preview()
}
