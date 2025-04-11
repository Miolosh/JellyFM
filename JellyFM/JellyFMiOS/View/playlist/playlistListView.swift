//
//  SongListView.swift
//  My Own Mediaplayer
//
//  Created by Toon van der Have on 09/02/2025.
//

import SwiftUI
import SwiftData

struct playlistListView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [user]
    @Query private var playlists: [playlist]
    
    @StateObject private var songList:ItemAPI
    
    @State var songlistNeedReload = false
    @State var searchText = ""
    
    // UserDefaults Keys
    enum UserDefaultsKeys {
        static let sortingOption = "sortingOption"
        static let ascendingOrder = "ascendingOrder"
    }
    
    // Sorting Options
    enum SortingOption: String, CaseIterable, Identifiable {
        case titleAscending = "Title"
        /*case artistAscending = "Artist"
        case dateCreated = "Date added"
        case datePremiered = "Releasedate"*/
        
        var id: String { self.rawValue }
    }
    
    // Load initial values from UserDefaults
    @State private var sortingOption: SortingOption = SortingOption(
        rawValue: UserDefaults.standard.string(forKey: UserDefaultsKeys.sortingOption) ?? SortingOption.titleAscending.rawValue
    ) ?? .titleAscending
    
    @State private var ascendingOrder: Bool = UserDefaults.standard.bool(forKey: UserDefaultsKeys.ascendingOrder)
    
    // Sorting Logic
    var sortedLists: [playlist] {
        var sorted: [playlist]
        switch sortingOption {
        case .titleAscending:
            sorted = playlists.sorted { $0.name.lowercased() < $1.name.lowercased() }
            /*case .artistAscending:
             sorted = playlists.sorted { $0.artist[0].lowercased() < $1.artist[0].lowercased() }
             case .dateCreated:
             sorted = playlists.sorted { $0.dateCreated < $1.dateCreated }
             case .datePremiered:
             sorted = playlists.sorted { $0.premiereDate < $1.premiereDate }*/
        }
        
        
        if searchText.isEmpty{
            
        }else{
            sorted = sorted.filter { $0.name.lowercased().contains(searchText.lowercased())}
        }
        
        return ascendingOrder ? sorted : sorted.reversed()
        
    }
    
    init() {
        _songList = StateObject(wrappedValue: ItemAPI())
    }
    
    var body: some View {
        
        VStack(alignment: .leading){
            List {
                searchBar(searchText: $searchText)
                
                ForEach(sortedLists) { item in
                    playlistView(listedPlaylist: item, newUser: users[0])
                    }
                
                HStack{
                    Spacer()
                    Image("InAppIcon")
                            .resizable()
                            .frame(width: 100, height: 100)
                    Spacer()
                }
                .listRowSeparator(.hidden)
            }.navigationTitle("Playlists")
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
            songList.checkSongs(searchType: "Playlist", user: users[0])
        }else{
            songList.increaseLoadedSongs(searchType: "Playlist", user: users[0])
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
        let jellyFinItems = songList.songs
        var allSongs = [playlist]()
        
        for thisItem in jellyFinItems{
            allSongs.append(playlist(
                id: thisItem.id,
                name: thisItem.title
            ))

        }
        
        for refreshedSong in allSongs{
            modelContext.insert(refreshedSong)
        }
        
    }
    
    func deleteSongs(){
        for thisList in playlists{
            modelContext.delete(thisList)
        }
     
    }

}
    
    

#Preview {
    SongListView()
        .modelContainer(for: song.self, inMemory: true)
}
