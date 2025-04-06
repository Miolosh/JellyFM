//
//  homePage.swift
//  My Own Mediaplayer
//
//  Created by Toon van der Have on 10/02/2025.
//

import SwiftUI
import SwiftData
import AVKit

struct homePage: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [user]
    @Query private var albums: [album]
    
    @State var showSettings: Bool = false
    
    // Define a grid layout with two columns
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ZStack {
            if users.isEmpty {
                ContentView()
            } else {
                NavigationView {
                    
                    List {
                        // Top navigation links
                        NavigationLink {
                            SongListView()
                        } label: {
                            HStack {
                                Image(systemName: "music.note").foregroundColor(Color.green)
                                Text("Songs")
                            }
                        }
                        
                        NavigationLink {
                            albumListView()
                        } label: {
                            HStack {
                                Image(systemName: "rectangle.stack").foregroundColor(Color.green)
                                Text("Albums")
                            }
                        }
                        NavigationLink {
                            playlistListView()
                        } label: {
                            HStack {
                                Image(systemName: "rectangle.stack").foregroundColor(Color.green)
                                Text("Playlists")
                            }
                        }
                        NavigationLink {
                            artistListView()
                        } label: {
                            HStack {
                                Image(systemName: "music.microphone").foregroundColor(Color.green)
                                Text("Artists")
                            }
                        }
                        
#if os(iOS)
                        // Section for grid
                        Section(header: Text("Recently added")
                            .font(.system(size: 36))
                            .fontWeight(.bold)
                            .foregroundColor(Color.black)
                            .listRowSeparator(.hidden))
                        {
                            albumLastAddedHorizontal(albums: albums, currentUser: users[0])
                            
                        }
                        .listRowSeparator(.hidden)
#endif
                    }
                    .navigationTitle("Home")
                    .toolbar {
                        ToolbarItem{
                            AirPlayButton()
                        }
                        ToolbarItem {
                            Button(action: toggleSettings) {
                                Label("Settings", systemImage: "gear")
                            }
                        }
                        
                    }
                    .onAppear(){
                        if MusicPlayer.shared.activeUser == nil{
                            MusicPlayer.shared.activeUser = users[0]
                        }
                    }
                }.sheet(isPresented: $showSettings){
                    settingsView()
                }
                
            }
        }
        .listStyle(.inset)
        .accentColor(.green)
        .overlay(
            BottomPlayerView(),
            alignment: .bottom
        )
    }

    func toggleSettings(){
        showSettings.toggle()
    }
    
    
}

#Preview {
    homePage()
        .modelContainer(for: user.self, inMemory: true)
}

