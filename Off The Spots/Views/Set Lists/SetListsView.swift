//
//  SetListsView.swift
//  Off The Spots
//
//  Created by David Freeman on 7/16/25.
//

import SwiftUI
import SwiftData

struct SetListsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\SetList.order)]) private var setLists: [SetList]
    
    var setSelectedSong: (Song, SetList?, Bool) -> Void = {song, setList, skip in }
    @Binding var presentPlayerSheet: Bool
    @Binding var hideMiniPlayer: Bool
    @Binding var setListNavPath: NavigationPath
    
    var selectedSong: Song?
    var selectedSetList: SetList?
    var isSongPlaying: Bool
    
    @State private var selection = Set<SetList.ID>()
    
    @State private var presentAddSetListSheet: Bool = false
    @State var newSetList: SetList = SetList(
        id: UUID(),
        name: "",
        songs: []
    )
    
    @Environment(\.otsProGroupId) var otsProGroupId
    @State private var isPro: Bool = false
    @State private var presentSubscription: Bool = false
    @State private var presentThanksSheet: Bool = false
    
    var body: some View {
        NavigationStack(path: $setListNavPath) {
            Group {
                if setLists.isEmpty {
                    SplashScreenView()
                } else {
                    List(selection: $selection) {
                        ForEach(setLists) { setList in
                            Button(action: {
                                if isPro {
                                    setListNavPath.append(setList)
                                } else {
                                    presentSubscription = true
                                }
                            }) {
                                SetListItemView(
                                    setList: setList,
                                    selectedSetList: selectedSetList,
                                    isSongPlaying: isSongPlaying
                                )
                                .foregroundStyle(isPro ? .primary : .secondary)
                            }
                            .listRowBackground(listItemBackground)
                        }
                        .onMove(perform: moveSetLists)
                        .onDelete(perform: deleteSetLists)
                    }
                    .scrollContentBackground(.hidden)
                    .listSectionSpacing(.compact)
                    .ignoresSafeArea(.keyboard)
                    .navigationDestination(for: SetList.self) { setList in
                        SetListView(
                            setList: setList,
                            presentPlayerSheet: $presentPlayerSheet,
                            setSelectedSong: setSelectedSong,
                            selectedSong: selectedSong,
                            selectedSetList: selectedSetList,
                            isSongPlaying: isSongPlaying
                        )
                    }
                }
            }
            .navigationTitle("Set Lists")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink(destination: SettingsView(hideMiniPlayer: $hideMiniPlayer), label: {Image(systemName: "gearshape") })
                }
                
                if(!setLists.isEmpty) {
                    ToolbarItem(placement: .topBarTrailing) {
                        EditButton()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        if isPro {
                            newSetList = SetList(
                                id: UUID(),
                                name: "",
                                songs: []
                            )
                            
                            presentAddSetListSheet = true
                        } else {
                            presentSubscription = true
                        }
                    }, label: {
                        Image(systemName: "plus")
                    })
                    .accessibilityLabel("Add Set List")
                    .sheet(isPresented: $presentAddSetListSheet) {
                        EditSetListView(setList: $newSetList)
                            .interactiveDismissDisabled(true)
                    }
                }
            }
            .onAppear { hideMiniPlayer = false }
            .background(backgroundGradient)
            .sheet(isPresented: $presentSubscription) { SubscriptionView(presentThanksSheet: $presentThanksSheet, inSheet: true) }
            .sheet(isPresented: $presentThanksSheet) { ThanksView() }
            .subscriptionStatusTask(for: otsProGroupId) { taskState in
                if let statuses = taskState.value {
                    isPro = StoreHelper().checkForActiveSubscription(in: statuses)
                } else {
                    isPro = false
                }
            }
        }
    }
    
    private func deleteSetLists(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(setLists[index])
            }
        }
    }
    
    private func moveSetLists(offsets: IndexSet, destination: Int) {
        withAnimation {
            var revisedSetLists = setLists
            revisedSetLists.move(fromOffsets: offsets, toOffset: destination)
            for (newIndex, setList) in revisedSetLists.enumerated() {
                if setList.order != newIndex {
                    setList.order = newIndex
                }
            }

            try? modelContext.save()
        }
    }
}

#Preview {
    @Previewable @State var path = NavigationPath()
    
    let container: ModelContainer = {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: SetList.self, configurations: config)
        for i in 1..<10 {
            let track = Track(name: "Track 1", file: nil)
            let song = Song(name: "Song \(i)", tracks: [track], selectedTrack: track, sheetMusic: nil)
            let setList = SetList(name: "Set List \(i)", songs: [song.id])
            container.mainContext.insert(setList)
        }
        return container
    }()

    return SetListsView(
        presentPlayerSheet: .constant(false),
        hideMiniPlayer: .constant(false),
        setListNavPath: $path,
        isSongPlaying: false
    )
    .modelContainer(container)
}
