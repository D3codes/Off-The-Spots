//
//  AddSongView.swift
//  Off The Spots
//
//  Created by David Freeman on 12/4/24.
//

import SwiftUI

struct AddSongView: View {
    @Binding var presentAddSongPopover: Bool
    var addSong: (_ song: Song) -> Void
    
    let songId: UUID = UUID()
    @State var songTitle: String = ""
    @State var tracks: [Track] = []
    
    @State private var presentFileImporter: Bool = false
    
    var body: some View {
        VStack {
            Group {
                VStack(spacing: 0) {
                    Text("Song Name")
                        .font(.title2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    TextField("", text: $songTitle)
                        .textFieldStyle(.roundedBorder)
                        .font(.largeTitle)
                }
                .padding(.bottom, 40)
                
                HStack {
                    Text("Tracks")
                        .font(.title2)
                    
                    Spacer()
                    
                    Button(action: { presentFileImporter = true }, label: {
                        Image(systemName: "plus")
                            .font(.title2)
                    })
                }
            }
            .padding()
            List {
                ForEach(0..<tracks.count, id: \.self) { index in
                    TextField("", text: self.$tracks[index].name)
                }
                .onDelete(perform: deleteTracks)
            }
            .scrollContentBackground(.hidden)
            .background(.quaternary)
        }
        .safeAreaInset(edge: .top) {
            HStack {
                Button(action: { presentAddSongPopover = false }, label: {
                    Text("Cancel")
                        .font(.title2)
                })
                
                Spacer()
                
                Button(action: {
                    addSong(Song(name: songTitle, tracks: tracks, selectedTrack: tracks[0]))
                    presentAddSongPopover = false
                }, label: {
                    Text("Save")
                        .font(.title2)
                })
                .disabled(songTitle.isEmpty || tracks.isEmpty)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 15)
            .background(.thickMaterial)
        }
        .fileImporter(
            isPresented: $presentFileImporter,
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
            tracks.append(Track(name: fileUrl.lastPathComponent, file: file))
        } catch {
            
        }
    }
    
    private func deleteTracks(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                tracks.remove(at: index)
            }
        }
    }
}

#Preview {
    struct AddSongView_Preview: View {
        @State var presentAddSongPopover: Bool = false
        
        var body: some View {
            AddSongView(
                presentAddSongPopover: $presentAddSongPopover,
                addSong: { _ in },
                songTitle: "After You've Gone",
                tracks: [
                    Track(name: "Bass Left"),
                    Track(name: "Bari Left"),
                    Track(name: "Lead Left"),
                    Track(name: "Tenor Left")
                ]
            )
        }
    }
    
    return AddSongView_Preview()
}
