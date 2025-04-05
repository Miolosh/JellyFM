//
//  SongListView.swift
//  My Own Mediaplayer
//
//  Created by Toon van der Have on 09/02/2025.
//

import SwiftUI
import SwiftData

struct artistListView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query private var artists: [artist]
    @Query private var users: [user]
    
    @StateObject private var songList:ItemAPI
    
    @State var songlistNeedReload = false
    @State var searchText = ""
    
    // UserDefaults Keys
    enum UserDefaultsKeys {
        static let sortingOptionArtist = "sortingOptionArtist"
        static let ascendingOrderArtist = "ascendingOrderArtist"
    }
    
    // Sorting Options
    enum SortingOption: String, CaseIterable, Identifiable {
        case nameAscending = "Name"
        //case artistAscending = "Artist"
        
        var id: String { self.rawValue }
    }
    
    // Load initial values from UserDefaults
    @State private var sortingOption: SortingOption = SortingOption(
        rawValue: UserDefaults.standard.string(forKey: UserDefaultsKeys.sortingOptionArtist) ?? SortingOption.nameAscending.rawValue
    ) ?? .nameAscending
    
    @State private var ascendingOrder: Bool = UserDefaults.standard.bool(forKey: UserDefaultsKeys.ascendingOrderArtist)
    
    // Sorting Logic
    var sortedArtists: [artist] {
        var sorted: [artist]
        switch sortingOption {
        case .nameAscending:
            sorted = artists.sorted { $0.name.lowercased() < $1.name.lowercased() }
        /*case .artistAscending:
            sorted = artists.sorted { $0.artistName[0].lowercased() < $1.artistName[0].lowercased() }*/
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
                
                ForEach(sortedArtists) { item in
                    artistView(listedArtist: item, newUser: users[0])
                    }
                HStack{
                    Spacer()
                    Image("InAppIcon")
                            .resizable()
                            .frame(width: 100, height: 100)
                    Spacer()
                }
                .listRowSeparator(.hidden)
            }.navigationTitle("Artists")
                .listStyle(.inset)
#if os(iOS)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            ascendingOrder.toggle()
                            UserDefaults.standard.set(ascendingOrder, forKey: UserDefaultsKeys.ascendingOrderArtist)
                        } label: {
                            Label("Sort", systemImage: ascendingOrder ? "arrow.up" : "arrow.down")
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            ForEach(SortingOption.allCases) { option in
                                Button(action: {
                                    sortingOption = option
                                    UserDefaults.standard.set(option.rawValue, forKey: UserDefaultsKeys.sortingOptionArtist)
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
            resetArtists(initial: true)
        }
        .onReceive(songList.$lastUpdated){newState in
            //if statement was added to prevent a deletion of all items in model.
            //songList reinitialized when view opens, making the lastUpdated value empty and triggering this statement.
            if songlistNeedReload{
                
                if(songList.currentPosition <= songList.amountOfLoadsAtSameTime){
                    loadArtistsInModel(deletion: true)
                    resetArtists(initial: false)
                }else{
                    loadArtistsInModel(deletion: false)
                }
            }
            self.songlistNeedReload = true
        
        }
        .onReceive(songList.$lastIncrement){newSong in //lastIncrement is used since this is only updated if a load has occured and is not reset.
            if (songList.currentPosition != 0){
                loadArtistsInModel(deletion: false)
                resetArtists(initial: false)
            }
            
        }
    }
    
    func resetArtists(initial: Bool){
        if initial{
            songList.checkSongs(searchType: "artist", user: users[0])
        }else{
            songList.increaseArtists(user: users[0])
        }
    }
    
    //is called when lastupdated changed
    func loadArtistsInModel(deletion: Bool){
        if deletion{
            deleteSongs()
        }
        increaseArtistsInModel()
    }
    
    //is called when a second loop has been gone through
    func increaseArtistsInModel(){
        let jellyFinItems = songList.artists
        var allArtists = [artist]()
        
        for thisItem in jellyFinItems{
            allArtists.append(artist(id: thisItem.id, name: thisItem.name))

        }
        
        for refreshedSong in allArtists{
            modelContext.insert(refreshedSong)
        }
        
    }
    
    func deleteSongs(){
        for thisArtist in artists{
            modelContext.delete(thisArtist)
        }
     
    }

}
    
    

#Preview {
    SongListView()
        .modelContainer(for: song.self, inMemory: true)
}
