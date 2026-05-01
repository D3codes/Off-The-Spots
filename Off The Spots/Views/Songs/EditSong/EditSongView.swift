//
//  EditSongView.swift
//  Off The Spots
//
//  Created by David Freeman on 12/4/24.
//

import SwiftUI

struct TrackDraft: Identifiable {
    let id: UUID
    var name: String
    var file: Data?

    init(track: Track) {
        id = track.id
        name = track.name
        file = track.file
    }

    init(id: UUID = UUID(), name: String, file: Data?) {
        self.id = id
        self.name = name
        self.file = file
    }
}

struct SheetMusicDraft: Identifiable {
    let id: UUID
    var name: String
    var file: Data?

    init(sheetMusic: SheetMusic) {
        id = sheetMusic.id
        name = sheetMusic.name
        file = sheetMusic.file
    }

    init(id: UUID = UUID(), name: String, file: Data?) {
        self.id = id
        self.name = name
        self.file = file
    }
}

struct EditSongView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var sheetTitle: String = "Add Song"
    
    @Binding var song: Song
    var isNewSong: Bool = false
    @FocusState var isSongFieldFocused: Bool
    
    @Environment(\.otsProGroupId) var otsProGroupId
    @State private var isPro: Bool = false
    @State private var presentSubscription: Bool = false
    @State private var presentThanksSheet: Bool = false
    @State private var songNameDraft: String = ""
    @State private var trackDrafts: [TrackDraft] = []
    @State private var sheetMusicDraft: SheetMusicDraft?
    @State private var didLoadDrafts: Bool = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    TextField("New Song", text: $songNameDraft)
                        .focused($isSongFieldFocused)
                } header: {
                    Text("Name")
                        .font(.subheadline)
                }
//                .listRowBackground(listItemBackground)
                
                SheetMusicListSectionView(sheetMusicDraft: $sheetMusicDraft, isPro: isPro, presentSubscription: $presentSubscription)
                
                TrackListSectionView(trackDrafts: $trackDrafts, isPro: isPro, presentSubscription: $presentSubscription)
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
                        applyDrafts()
                        if isNewSong {
                            modelContext.insert(song)
                        }
                        try? modelContext.save()
                        dismiss()
                    })
                    .disabled(songNameDraft.isEmpty || trackDrafts.isEmpty)
                }
            }
        }
        .onAppear {
            if !didLoadDrafts {
                loadDrafts()
            }

            if(!songNameDraft.isEmpty) {
                sheetTitle = "Edit Song"
            } else {
                isSongFieldFocused = true
            }
        }
        .sheet(isPresented: $presentSubscription) { SubscriptionView(presentThanksSheet: $presentThanksSheet, inSheet: true) }
        .sheet(isPresented: $presentThanksSheet) { ThanksView() }
        .subscriptionStatusTask(for: otsProGroupId) { taskState in
            isPro = StoreHelper.checkForActiveSubscription(in: taskState)
        }
//        .background(backgroundGradient)
    }

    private func loadDrafts() {
        songNameDraft = song.name
        trackDrafts = song.sortedTracks.map { TrackDraft(track: $0) }
        if let sheetMusic = song.sheetMusic {
            sheetMusicDraft = SheetMusicDraft(sheetMusic: sheetMusic)
        } else {
            sheetMusicDraft = nil
        }
        didLoadDrafts = true
    }

    private func applyDrafts() {
        song.name = songNameDraft

        let tracks = song.tracks ?? []
        let tracksById = Dictionary(uniqueKeysWithValues: tracks.map { ($0.id, $0) })
        var committedTracks: [Track] = []

        for (index, draft) in trackDrafts.enumerated() {
            let track = tracksById[draft.id] ?? Track(id: draft.id)
            track.name = draft.name
            track.file = draft.file
            track.order = index
            committedTracks.append(track)
        }

        let committedTrackIds = Set(committedTracks.map(\.id))
        for track in tracks where !committedTrackIds.contains(track.id) {
            modelContext.delete(track)
        }

        song.tracks = committedTracks
        song.selectedTrack = committedTracks.first

        if let draft = sheetMusicDraft {
            let sheetMusic = song.sheetMusic?.id == draft.id ? song.sheetMusic! : SheetMusic(id: draft.id)
            sheetMusic.name = draft.name
            sheetMusic.file = draft.file

            if let existingSheetMusic = song.sheetMusic, existingSheetMusic.id != draft.id {
                modelContext.delete(existingSheetMusic)
            }
            song.sheetMusic = sheetMusic
        } else {
            if let existingSheetMusic = song.sheetMusic {
                modelContext.delete(existingSheetMusic)
            }
            song.sheetMusic = nil
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
                EditSongView(song: $song, isNewSong: true)
                    .interactiveDismissDisabled(true)
            }
        }
    }
    
    return EditSongView_Preview()
}
