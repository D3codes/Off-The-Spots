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

    var body: some View {
        NavigationStack {
            List {
                Section {
                    TextField("New Song", text: $song.name)
                        .focused($isSongFieldFocused)
                } header: {
                    Text("Name")
                        .font(.subheadline)
                }
//                .listRowBackground(listItemBackground)
                
                SheetMusicListSectionView(song: song)
                
                TrackListSectionView(song: song)
            }
            .scrollContentBackground(.hidden)
            .listSectionSpacing(.compact)
            .navigationTitle(Text(sheetTitle))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(role: .cancel, action: { dismiss() })
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(role: .confirm, action: {
                        song.selectedTrack = song.tracks[0]
                        modelContext.delete(song)
                        modelContext.insert(song)
                        dismiss()
                    })
                    .disabled(song.name.isEmpty || song.tracks.isEmpty)
                }
            }
        }
        .onAppear {
            if(!song.name.isEmpty) {
                sheetTitle = "Edit Song"
            } else {
                isSongFieldFocused = true
            }
        }
//        .background(backgroundGradient)
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
            }
        }
    }
    
    return EditSongView_Preview()
}
