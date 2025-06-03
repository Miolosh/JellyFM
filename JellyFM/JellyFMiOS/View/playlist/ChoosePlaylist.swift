//
//  SongListView.swift
//  My Own Mediaplayer
//
//  Created by Toon van der Have on 09/02/2025.
//

import SwiftUI
import SwiftData

struct ChoosePlaylist: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [user]
    @Query private var playlists: [playlist]
    
    @StateObject private var songList:ItemAPI
    
    @State var songlistNeedReload = false
    @State var searchText = ""
    
    var songID: String
    
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
    
    init(songId: String) {
        _songList = StateObject(wrappedValue: ItemAPI())
        self.songID = songId
    }
    
    var body: some View {
        
        VStack(alignment: .leading){
            List {
                Text("Add song to playlist")
                    .font(.headline)
                searchBar(searchText: $searchText)
                
                ForEach(sortedLists) { item in
                    Button(action:{
                        addToPlayList(songToAdd: songID, playlistToAddTo: item)
                    })
                    {
                        //the false makes the list look pale
                        playlistView(listedPlaylist: item, newUser: users[0], isNavigationLink: false)
                    }
                    
                }
                
                HStack{
                    Spacer()
                    Image("InAppIcon")
                        .resizable()
                        .frame(width: 100, height: 100)
                    Spacer()
                }
                .listRowSeparator(.hidden)
            }
            .navigationTitle("Choose playlist")
            .listStyle(.inset)
        }
    }
    
    func addToPlayList(songToAdd: String, playlistToAddTo: playlist){
        songList.addSongToPlaylist(currentUser: users[0], playlistId: playlistToAddTo.id, songId: songToAdd)
        
    }

}
    
    

#Preview {
    SongListView()
        .modelContainer(for: song.self, inMemory: true)
}
