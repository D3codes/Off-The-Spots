//
//  TrackListSectionView.swift
//  Off The Spots
//
//  Created by David Freeman on 10/24/25.
//

import SwiftUI

struct TrackListSectionView: View {
    @State var song: Song
    
    @State private var presentTrackFileImporter: Bool = false
    
    var body: some View {
        Section {
            ForEach(0..<song.tracks.count, id: \.self) { index in
                TextField("", text: self.$song.tracks[index].name)
            }
            .onMove(perform: moveTracks)
            .onDelete(perform: deleteTracks)
            .scrollContentBackground(.hidden)
            .listSectionSpacing(.compact)
            .listRowBackground(listItemBackground)
        } header: {
            HStack {
                Image(systemName: "music.note.square.stack.fill")
                    .font(.subheadline)
                Text("Tracks")
                    .font(.subheadline)
                
                Spacer()
                
                Button(action: { presentTrackFileImporter = true }) {
                    Image(systemName: "plus")
                        .font(.title2)
                        .foregroundStyle(.foreground)
                        .frame(width: 10, height: 20)
                }
                .font(.subheadline)
                .buttonStyle(.bordered)
            }
        } footer: {
            if(song.tracks.isEmpty) {
                Text("No Tracks")
                    .foregroundStyle(.secondary)
                    .font(.title3)
                    .frame(maxWidth: .infinity)
                    .padding(.top)
            }
        }
        .fileImporter(
            isPresented: $presentTrackFileImporter,
            allowedContentTypes: [.mp3],
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
                    addTrack(fileUrl: fileUrls[0])
                    
                    // release access
                    fileUrls[0].stopAccessingSecurityScopedResource()
                    
                case .failure(let error):
                    print("Error: \(error)")
                }
            })
    }
    
    func addTrack(fileUrl: URL) {
        do {
            let file: Data = try Data(contentsOf: fileUrl)
            song.tracks.append(Track(name: fileUrl.deletingPathExtension().lastPathComponent, file: file))
        } catch {
            
        }
    }
    
    private func deleteTracks(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                song.tracks.remove(at: index)
            }
        }
    }

    private func moveTracks(offsets: IndexSet, destination: Int) {
        withAnimation {
            song.tracks.move(fromOffsets: offsets, toOffset: destination)
        }
    }
}

#Preview {
    struct TrackListView_Preview: View {
        @State private var song: Song = Song(name: "Test Song", tracks: [], selectedTrack: Track(name: "Track 1"))
        
        var body: some View {
            List {
                TrackListSectionView(song: song)
            }
        }
    }
    
    return TrackListView_Preview()
}
