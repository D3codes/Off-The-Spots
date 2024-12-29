//
//  AddSongView.swift
//  Off The Spots
//
//  Created by David Freeman on 12/4/24.
//

import SwiftUI

struct AddSongView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let songId: UUID = UUID()
    @State var songTitle: String = ""
    @State var tracks: [Track] = []
    @FocusState var isSongFieldFocused: Bool

    @State private var presentFileImporter: Bool = false

    var body: some View {
        List {
            Section {
                TextField("New Song", text: $songTitle)
                    .focused($isSongFieldFocused)
                    .onAppear { isSongFieldFocused = true }
            } header: {
                Text("Name")
                    .font(.subheadline)
            }
            
            Section {
                ForEach(0..<tracks.count, id: \.self) { index in
                    TextField("", text: self.$tracks[index].name)
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
                if tracks.isEmpty {
                    Text("No Tracks")
                        .foregroundStyle(.secondary)
                        .font(.title3)
                        .frame(maxWidth: .infinity)
                        .padding(.top)
                }
            }
        }
        .navigationTitle(Text("Add Song"))
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
                modelContext.insert(Song(name: songTitle, tracks: tracks, selectedTrack: tracks[0]))
                dismiss()
            }) {
                Text("Save")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding()
            .disabled(songTitle.isEmpty || tracks.isEmpty)
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

    private func moveTracks(offsets: IndexSet, destination: Int) {
        withAnimation {
            tracks.move(fromOffsets: offsets, toOffset: destination)
        }
    }
}

#Preview {
    struct AddSongView_Preview: View {
        @State var presentAddSongPopover: Bool = false
        
        var body: some View {
            AddSongView(
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
