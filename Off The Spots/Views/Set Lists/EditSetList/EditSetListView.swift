//
//  EditSetListView.swift
//  Off The Spots
//
//  Created by David Freeman on 10/29/25.
//

import SwiftUI
import SwiftData

struct EditSetListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var sheetTitle: String = "Add Set List"
    
    @Binding var setList: SetList
    var dismissSubView: () -> Void = { }
    
    @FocusState var isNameFieldFocused: Bool

    var body: some View {
        NavigationStack {
            List {
                Section {
                    TextField("New Set List", text: $setList.name)
                        .focused($isNameFieldFocused)
                } header: {
                    Text("Name")
                        .font(.subheadline)
                }
                .listRowBackground(listItemBackground)
                
                SongListSectionView(setList: setList)
            }
            .scrollContentBackground(.hidden)
            .navigationTitle(Text(sheetTitle))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(role: .cancel, action: { dismiss() })
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(role: .confirm, action: {
                        modelContext.delete(setList)
                        modelContext.insert(setList)
                        dismiss()
                        dismissSubView()
                    })
                    .disabled(setList.name.isEmpty)
                }
            }
            .background(backgroundGradient)
        }
        .onAppear {
            if(!setList.name.isEmpty) {
                sheetTitle = "Edit Set List"
            } else {
                isNameFieldFocused = true
            }
        }
    }
}

#Preview {
    struct EditSetListView_Preview: View {
        @State var presentAddSetListPopover: Bool = true
        @State var setList: SetList = SetList(
            id: UUID(),
            name: "",
            songs: []
        )
        
        let container: ModelContainer = {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try! ModelContainer(for: Song.self, configurations: config)
            for i in 1..<10 {
                let track = Track(name: "Track 1", file: nil)
                let song = Song(name: "Song \(i)", tracks: [track], selectedTrack: track, sheetMusic: nil)
                container.mainContext.insert(song)
            }
            return container
        }()
        
        var body: some View {
            VStack {
                Text("Test")
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .sheet(isPresented : $presentAddSetListPopover) {
                EditSetListView(setList: $setList)
                    .interactiveDismissDisabled(true)
                    .modelContainer(container)
            }
        }
    }
    
    return EditSetListView_Preview()
}
