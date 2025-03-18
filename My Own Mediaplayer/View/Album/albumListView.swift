//
//  SongListView.swift
//  My Own Mediaplayer
//
//  Created by Toon van der Have on 09/02/2025.
//

import SwiftUI
import SwiftData

struct albumListView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query private var albums: [album]
    @Query private var users: [user]
    
    @StateObject private var songList:ItemAPI
    
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
    
    // Sorting Logic
    var sortedAlbums: [album] {
        let sorted: [album]
        switch sortingOption {
        case .titleAscending:
            sorted = albums.sorted { $0.title.lowercased() < $1.title.lowercased() }
        case .artistAscending:
            sorted = albums.sorted { $0.artist[0].lowercased() < $1.artist[0].lowercased() }
        case .dateCreated:
            sorted = albums.sorted { $0.dateCreated < $1.dateCreated }
        }
        return ascendingOrder ? sorted : sorted.reversed()
    }
    
    init() {
        _songList = StateObject(wrappedValue: ItemAPI())
    }
    
    var body: some View {
        
        VStack(alignment: .leading){
            List {
                ForEach(sortedAlbums) { item in
                    albumView(listedAlbum: item, newUser: users[0])
                    }
            }.navigationTitle("Albums")
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
            resetAlbums(initial: true)
        }
        .onReceive(songList.$lastUpdated){newState in
            //if statement was added to prevent a deletion of all items in model.
            //songList reinitialized when view opens, making the lastUpdated value empty and triggering this statement.
            if songlistNeedReload{
                
                if(songList.currentPosition <= songList.amountOfLoadsAtSameTime){
                    loadAlbumsInModel(deletion: true)
                    resetAlbums(initial: false)
                }else{
                    loadAlbumsInModel(deletion: false)
                }
            }
            self.songlistNeedReload = true
        
        }
        .onReceive(songList.$lastIncrement){newSong in //lastIncrement is used since this is only updated if a load has occured and is not reset.
            if (songList.currentPosition != 0){
                loadAlbumsInModel(deletion: false)
                resetAlbums(initial: false)
            }
            
        }
    }
    
    func resetAlbums(initial: Bool){
        if initial{
            songList.checkSongs(searchType: "MusicAlbum", user: users[0])
        }else{
            songList.increaseLoadedSongs(searchType: "MusicAlbum", user: users[0])
        }
    }
    
    //is called when lastupdated changed
    func loadAlbumsInModel(deletion: Bool){
        if deletion{
            deleteSongs()
        }
        increaseAlbumsInModel()
    }
    
    //is called when a second loop has been gone through
    func increaseAlbumsInModel(){
        var jellyFinItems = songList.songs
        var allSongs = [album]()
        
        for thisItem in jellyFinItems{
            allSongs.append(album(id: thisItem.id, title: thisItem.title, artist: thisItem.artist ?? [], albumid: thisItem.albumId, albumArtist: thisItem.albumArtist, dateCreated: thisItem.dateCreated, albumArtistId: thisItem.albumArtistId, parentId: thisItem.parentId))

        }
        
        for refreshedSong in allSongs{
            print(refreshedSong.title)
            modelContext.insert(refreshedSong)
        }
        
    }
    
    func deleteSongs(){
        for thisAlbum in albums{
            modelContext.delete(thisAlbum)
        }
     
    }

}
    
    

#Preview {
    SongListView()
        .modelContainer(for: song.self, inMemory: true)
}
