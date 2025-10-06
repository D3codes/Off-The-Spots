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
        VStack {
            HStack {
                Button(role: .cancel, action: { dismiss() }, label: {
                    Image(systemName: "xmark")
                        .frame(width: 20, height: 30)
                        .font(.title2)
                })
                .buttonStyle(.glass)
                
                Spacer()
                
                Button(role: .confirm, action: {
                    song.selectedTrack = song.tracks[0]
                    modelContext.delete(song)
                    modelContext.insert(song)
                    dismiss()
                }) {
                    Image(systemName: "checkmark")
                        .frame(width: 20, height: 30)
                        .font(.title2)
                        .foregroundStyle(song.name.isEmpty || song.tracks.isEmpty ? .gray : .primary)
                }
                .disabled(song.name.isEmpty || song.tracks.isEmpty)
                .buttonStyle(.glassProminent)
            }
            .padding(.horizontal)
            .padding(.top)
            .padding(.bottom)
            
            Text(sheetTitle)
                .font(.title)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
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
            }
            .scrollContentBackground(.hidden)
        }
//        .presentationBackground(LinearGradient(gradient: Gradient(colors: [.clear, .blue, .blue, .blue, .blue]/*[.otsblue, .clear, .clear, .clear, .clear]*/), startPoint: .top, endPoint: .bottom))
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
        @State var presentAddSongPopover: Bool = true
        @State var song: Song = Song(
            id: UUID(),
            name: "",
            tracks: [],
            selectedTrack: Track(name: "")
        )
        
        var body: some View {
            VStack {
                Text("Test")
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .sheet(isPresented : $presentAddSongPopover) {
                EditSongView(song: $song)
                    .interactiveDismissDisabled(true)
                    .presentationBackground(.ultraThinMaterial)
            }
        }
    }
    
    return EditSongView_Preview()
}
