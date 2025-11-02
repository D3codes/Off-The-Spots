//
//  AddToSetListView.swift
//  Off The Spots
//
//  Created by David Freeman on 10/31/25.
//

import SwiftUI
import SwiftData

struct AddToSetListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\SetList.order)]) private var setLists: [SetList]
    @Environment(\.dismiss) private var dismiss
    
    @State var song: Song
    
    @State private var presentAddSetListSheet: Bool = false
    @State var newSetList: SetList = SetList(
        id: UUID(),
        name: "",
        songs: []
    )
    
    @State private var searchText: String = ""
    var filteredSetLists: [SetList] {
        if searchText.isEmpty {
            return setLists
        } else {
            return setLists.filter { $0.name.contains(searchText) }
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button(action: {
                        newSetList = SetList(
                            id: UUID(),
                            name: "",
                            songs: [song.id]
                        )
                        
                        presentAddSetListSheet = true
                    }, label: {
                        HStack {
                            Image(systemName: "plus")
                            Text("New Set List")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Capsule())
                    })
                    .buttonStyle(.plain)
                    .sheet(isPresented: $presentAddSetListSheet) {
                        EditSetListView(setList: $newSetList, dismissSubView: { dismiss() })
                            .interactiveDismissDisabled(true)
                    }
                }
                .listRowBackground(listItemBackground)
                
                ForEach(filteredSetLists) { setList in
                    Button(action: {
                        addSongTo(setList: setList)
                        dismiss()
                    }, label: {
                        Text(setList.name)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .contentShape(Capsule())
                    })
                    .buttonStyle(.plain)
                    .listRowBackground(listItemBackground)
                }
            }
            .scrollContentBackground(.hidden)
            .listSectionSpacing(.compact)
            .ignoresSafeArea(.keyboard)
            .searchable(text: $searchText)
            .navigationTitle(Text("Add to Set List"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(role: .close, action: { dismiss() })
                }
            }
            .background(backgroundGradient)
        }
    }
    
    private func addSongTo(setList: SetList) {
        if !setList.songs.contains(song.id) {
            setList.songs.append(song.id)
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
    
    Text("Test")
        .sheet(isPresented: .constant(true)) {
            AddToSetListView(song: Song(name: "Song Name", tracks:[], selectedTrack: Track(name: "")))
                .modelContainer(container)
        }
}
