//
//  SongListView.swift
//  My Own Mediaplayer
//
//  Created by Toon van der Have on 09/02/2025.
//

import SwiftUI
import SwiftData
import AVKit

struct SongListView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query private var songs: [song]
    @Query private var users: [user]
    
    @StateObject private var songList: ItemAPI
    
    @State private var showingSheet = false
    @State var songlistNeedReload = false
    
    // UserDefaults Keys
    enum UserDefaultsKeys {
        static let sortingOption = "sortingOption"
        static let ascendingOrder = "ascendingOrder"
    }
    
    // Sorting Options
    enum SortingOption: String, CaseIterable, Identifiable {
        case titleAscending = "Title"
        case artistAscending = "Artist"
        case dateCreated = "Date created"
        
        var id: String { self.rawValue }
    }
    
    // Load initial values from UserDefaults
    @State private var sortingOption: SortingOption = SortingOption(
        rawValue: UserDefaults.standard.string(forKey: UserDefaultsKeys.sortingOption) ?? SortingOption.titleAscending.rawValue
    ) ?? .titleAscending
    
    @State private var ascendingOrder: Bool = UserDefaults.standard.bool(forKey: UserDefaultsKeys.ascendingOrder)
    
    init() {
        _songList = StateObject(wrappedValue: ItemAPI())
    }
    
    // Sorting Logic
    var sortedSongs: [song] {
        let sorted: [song]
        switch sortingOption {
        case .titleAscending:
            sorted = songs.sorted { $0.title.lowercased() < $1.title.lowercased() }
        case .artistAscending:
            sorted = songs.sorted { $0.artist[0].lowercased() < $1.artist[0].lowercased() }
        case .dateCreated:
            sorted = songs.sorted { $0.dateCreated < $1.dateCreated }
        }
        return ascendingOrder ? sorted : sorted.reversed()
    }
    
    var body: some View {
        VStack {
            List {
                ForEach(Array(sortedSongs.enumerated()), id: \.element.id) { (index, item) in
                    Button(action: {
                        MusicPlayer.shared.playSongAndQueue(queueNumber: index, currentUser: users[0], queueList: sortedSongs)
                    }) {
                        SongView(listedSong: item, newUser: users[0])
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                        Button {
                            MusicPlayer.shared.addSongToQueue(songToPlay: item, currentUser: users[0])
                        } label: {
                            Label("Add to queue", systemImage: "music.note.list")
                        }
                        .tint(.green)
                    }
                }
            }
            .navigationTitle("Songs")
            .listStyle(.inset)
#if os(iOS)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        ascendingOrder.toggle()
                        UserDefaults.standard.set(ascendingOrder, forKey: UserDefaultsKeys.ascendingOrder)
                    } label: {
                        Label("Sort", systemImage: ascendingOrder ? "arrow.up" : "arrow.down")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        ForEach(SortingOption.allCases) { option in
                            Button(action: {
                                sortingOption = option
                                UserDefaults.standard.set(option.rawValue, forKey: UserDefaultsKeys.sortingOption)
                            }) {
                                HStack {
                                    Text(option.rawValue)
                                    if sortingOption == option {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        Label("Sort", systemImage: "arrow.up.arrow.down")
                    }
                }
            }
#endif
        }
        .refreshable {
            resetSongs(initial: true)
        }
        .onReceive(songList.$lastUpdated) { _ in
            if songlistNeedReload {
                if songList.currentPosition <= songList.amountOfLoadsAtSameTime {
                    loadSongsInModel(deletion: true)
                    resetSongs(initial: false)
                } else {
                    loadSongsInModel(deletion: false)
                }
            }
            songlistNeedReload = true
        }
        .onReceive(songList.$lastIncrement) { _ in
            if songList.currentPosition != 0 {
                loadSongsInModel(deletion: false)
                resetSongs(initial: false)
            }
        }
    }
    
    func resetSongs(initial: Bool) {
        if initial {
            songList.checkSongs(searchType: "Audio", user: users[0])
        } else {
            songList.increaseLoadedSongs(searchType: "Audio", user: users[0])
        }
    }
    
    func loadSongsInModel(deletion: Bool) {
        if deletion { deleteSongs() }
        increaseSongsInModel()
    }
    
    func increaseSongsInModel() {
        let allSongs = songList.songs.map { thisItem in
            song(id: thisItem.id, title: thisItem.title, artist: thisItem.artist, albumid: thisItem.albumId, indexNumber: thisItem.indexNumber, dateCreated: thisItem.dateCreated, discNumber: thisItem.parentIndexNumber)
        }
        allSongs.forEach { modelContext.insert($0) }
    }
    
    func deleteSongs() {
        songs.forEach { modelContext.delete($0) }
    }
    
}

#Preview {
    SongListView()
        .modelContainer(for: song.self, inMemory: true)
}
