//
//  SearchView.swift
//  Off The Spots
//
//  Created by David Freeman on 7/15/25.
//

import SwiftUI
import SwiftData

struct SearchView: View {
    @Query(sort: [SortDescriptor(\Song.order)]) private var songs: [Song]
    @Binding var presentPlayerSheet: Bool
    var setSelectedSong: (_ song: Song) -> Void = {song in }
    
    @State private var searchText: String = ""
    
    var filteredSongs: [Song] {
        if searchText.isEmpty {
            return songs
        } else {
            return songs.filter { $0.name.contains(searchText) }
        }
    }
    
    var body: some View {
        NavigationStack {
            List() {
                Section {
                    ForEach(filteredSongs) { song in
                        Button(action: {
                            setSelectedSong(song)
                            presentPlayerSheet = true
                        }, label: {
                            Text(song.name)
                                .font(.title2)
                                .tint(.primary)
                        })
                        //                                .listRowBackground(
                        //                                    RoundedRectangle(cornerRadius: 20)
                        //                                        .fill(.ultraThinMaterial)
                        //                                        .glassEffect(.regular.interactive())
                        //                                )
                    }
                }
                header: { Text("Songs") }
                footer: {
                    if filteredSongs.isEmpty {
                        Text("No Songs")
                            .foregroundStyle(.secondary)
                            .font(.title3)
                            .frame(maxWidth: .infinity)
                            .padding(.top)
                    }
                }
                
                Section {
                    
                }
                header: { Text("Set Lists") }
                footer: {
                    if true {
                        Text("No Set Lists")
                            .foregroundStyle(.secondary)
                            .font(.title3)
                            .frame(maxWidth: .infinity)
                            .padding(.top)
                    }
                }
                
                //            Section {
                //                Spacer()
                //                    .listRowBackground(
                //                        RoundedRectangle(cornerRadius: 20)
                //                            .opacity(0)
                //                    )
                //            }
            }
            .searchable(text: $searchText)
            .scrollContentBackground(.hidden)
            .listSectionSpacing(.compact)
            .ignoresSafeArea(.keyboard)
            .navigationTitle("Search")
        }
    }
}

#Preview {
    struct SearchView_Preview: View {
        @State var presentPlayerSheet: Bool = false
        
        var body: some View {
            SearchView(presentPlayerSheet: $presentPlayerSheet)
        }
    }
    
    return SearchView_Preview()
}
