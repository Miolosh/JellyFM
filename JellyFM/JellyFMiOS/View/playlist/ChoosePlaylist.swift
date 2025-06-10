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
    @Environment(\.dismiss) var dismiss
    @Query private var users: [user]
    @Query private var playlists: [playlist]
    
    @StateObject private var songList:ItemAPI
    
    @State var songlistNeedReload = false
    @State var searchText = ""
    
    var currentSong: song
    
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
    
    init(song: song) {
        _songList = StateObject(wrappedValue: ItemAPI())
        self.currentSong = song
    }
    
    var body: some View {
        NavigationStack{
            VStack(alignment: .leading){
                HStack{
                    Spacer()
                    Text("Add song to playlist")
                        .font(.headline)
                        .padding(20)
                    Spacer()
                }
                
                HStack{
                    Spacer()
                    AsyncImage(url: MusicPlayer.shared.albumArtUrl(listedSong: currentSong, size: 64)) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width:64, height: 64)
                            .cornerRadius(10)
                    } placeholder: {
                        Image("InAppIcon")
                            .resizable()
                            .frame(width: 64, height: 64)
                    }
                    Spacer()
                }
                
                HStack{
                    Spacer()
                    Text(currentSong.title)
                        .foregroundColor(Color.black)
                    Spacer()
                }
                
                List {
                    
                    searchBar(searchText: $searchText)
                    
                    
                    NavigationLink(destination: createNewplayListView(currentSong: currentSong, currentUser: users[0])) {
                        HStack{
                            Image(systemName: "plus.square")
                                .resizable()
                                .frame(width:48, height:48)
                                .foregroundColor(.green)
                            Text("Create new playlist")
                        }
                    }
                    
                    
                    ForEach(sortedLists) { item in
                        Button(action:{
                            addToPlayList(songToAdd: currentSong.id, playlistToAddTo: item)
                            dismiss()
                        })
                        {
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
                .listStyle(.inset)
            }
            //.navigationTitle("Add song to playlist")
        }
    }
    
    func addToPlayList(songToAdd: String, playlistToAddTo: playlist){
        songList.addSongToPlaylist(currentUser: users[0], playlistId: playlistToAddTo.id, songId: songToAdd)
        
    }

}

struct createNewplayListView: View{
    
    @StateObject private var songList:ItemAPI
    
    
    var currentUser: user
    var currentSong: song
    
    @State private var name: String = ""
    @Environment(\.dismiss) var dismiss
    
    init(currentSong: song, currentUser: user) {
        _songList = StateObject(wrappedValue: ItemAPI())
        self.currentSong = currentSong
        self.currentUser = currentUser
    }
    
    var body: some View{
            List{
                Section(header:Text("Name your playlist")){
                    TextField("Playlist name", text: $name)
                }
                
                Section{
                    Button(action: {
                        createNewPlaylist()
                        dismiss()
                        dismiss()
                    }) {
                        Text("Create")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .listRowBackground(Color(UIColor.systemGroupedBackground))
                
            }
            .navigationTitle("Create playlist")
            .navigationBarTitleDisplayMode(.inline)
        
            .listStyle(.automatic)
        
    }
    
    func createNewPlaylist(){
        songList.addNewPlaylist(currentUser: currentUser,  songIds: [currentSong.id], songName: name)
    }
}
    

#Preview {
    var currentUser: user = user(loggingInUsername: "noUser", LoggingInToServer: "0.0.0.0", currentDeviceID: "NoDeviceId", currentDeviceType: "noType", currentClientVersion: "0", token: "0", currentUserId: "")
    
    createNewplayListView(currentSong: song(id: "String", title: "Levensloop", artist: ["Toon"], albumid: "300", dateCreated: Date.now , discNumber: 1, premiereDate: Date.now), currentUser: currentUser)
}
