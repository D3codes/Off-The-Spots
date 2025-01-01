//
//  EditSongView.swift
//  Off The Spots
//
//  Created by David Freeman on 12/4/24.
//

import SwiftUI

struct EditSongView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var sheetTitle: String = "Add Song"
    
    @Binding var song: Song
    @FocusState var isSongFieldFocused: Bool

    @State private var presentFileImporter: Bool = false

    var body: some View {
        List {
            Section {
                TextField("New Song", text: $song.name)
                    .focused($isSongFieldFocused)
                    .onAppear { isSongFieldFocused = true }
            } header: {
                Text("Name")
                    .font(.subheadline)
            }
            
            Section {
                ForEach(0..<song.tracks.count, id: \.self) { index in
                    TextField("", text: self.$song.tracks[index].name)
                }
                .onMove(perform: moveTracks)
                .onDelete(perform: deleteTracks)
                .scrollContentBackground(.hidden)
            } header: {
                HStack {
                    Text("Tracks")
                        .font(.subheadline)

                    Spacer()

                    Button(action: { presentFileImporter = true }) {
                        Image(systemName: "plus")
                        Text("Add")
                    }
                    .font(.subheadline)
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
        }
        .navigationTitle(Text(sheetTitle))
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
        }
        .safeAreaInset(edge: .bottom) {
            Button(action: {
                song.selectedTrack = song.tracks[0]
                modelContext.delete(song)
                modelContext.insert(song)
                dismiss()
            }) {
                Text("Save")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding()
            .disabled(song.name.isEmpty || song.tracks.isEmpty)
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
        .onAppear {
            if(!song.name.isEmpty) {
                sheetTitle = "Edit Song"
            }
        }
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
    struct EditSongView_Preview: View {
        @State var presentAddSongPopover: Bool = false
        @State var song: Song = Song(
            id: UUID(),
            name: "",
            tracks: [],
            selectedTrack: Track(name: "")
        )
        
        var body: some View {
            EditSongView(song: $song)
        }
    }
    
    return EditSongView_Preview()
}
