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
    
    @ObservedObject var player: AudioHelper
    @Binding var presentPlayerSheet: Bool
    @Binding var hideMiniPlayer: Bool
    
    @State private var selection = Set<SetList.ID>()
    
    @State private var presentAddSetListSheet: Bool = false
    @State var newSetList: SetList = SetList(
        id: UUID(),
        name: "",
        songs: []
    )
    
    var body: some View {
        NavigationStack {
            Group {
                if setLists.isEmpty {
                    SplashScreenView()
                } else {
                    List(selection: $selection) {
                        ForEach(setLists) { setList in
                            NavigationLink(destination: SetListView(setList: setList)) {
                                VStack(alignment: .leading) {
                                    Text(setList.name)
                                        .font(.title2)
                                        .tint(.primary)
                                        .multilineTextAlignment(.leading)
                                    
                                    HStack {
                                        Text("\(Image(systemName: "music.note")) \(setList.songs.count)")
                                            .font(.footnote)
                                            .tint(.primary)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .onMove(perform: moveSetLists)
                        .onDelete(perform: deleteSetLists)
                    }
                    .scrollContentBackground(.hidden)
                    .listSectionSpacing(.compact)
                    .ignoresSafeArea(.keyboard)
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
                        newSetList = SetList(
                            id: UUID(),
                            name: "",
                            songs: []
                        )
                        
                        presentAddSetListSheet = true
                    }, label: {
                        Image(systemName: "plus")
                    })
                    .accessibilityLabel("Add Song")
                    .sheet(isPresented: $presentAddSetListSheet) {
                        EditSetListView(setList: $newSetList)
                            .interactiveDismissDisabled(true)
                    }
                }
            }
            .onAppear { hideMiniPlayer = false }
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

    SetListsView(
        player: AudioHelper(),
        presentPlayerSheet: .constant(false),
        hideMiniPlayer: .constant(false)
    )
    .modelContainer(container)
}
