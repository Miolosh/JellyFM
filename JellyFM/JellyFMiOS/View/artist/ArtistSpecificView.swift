//
//  AlbumSpecificView.swift
//  My Own Mediaplayer
//
//  Created by Toon van der Have on 28/02/2025.
//

import SwiftUI
import SwiftData

struct artistSpecificView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var albums: [album]
    @Query private var users: [user]
    @Query private var songs: [song]
    
    var selectedArtist: artist
    
    var artistAlbums: [album] {
        
        return albums
        //we choose name instead of id, because we believe it will always be the same for the same artist
        //Id was not chosen, because we use the artists endpoint. This returns a different id then the items
            .filter { $0.albumArtist == selectedArtist.name }
        
    }
    
    var artistSongs:[song]{
        var allSongsOfArtists = songs.filter { song in
            song.artist.contains(where: { $0.lowercased().contains(selectedArtist.name.lowercased())})
        }
        
        return allSongsOfArtists
    }
    
    @State private var selection = 0
    
    
    var body: some View {
        List {
            ZStack{
                AsyncImage(url: URL(string: "\(users[0].serverIP)/Items/\(selectedArtist.id)/Images/Primary?fillHeight=480&fillWidth=480&quality=96&tag=726197babb87ba7515d495fad56d81ed")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .blur(radius: 100) // Create a soft glow
                        .scaleEffect(1.5) // Make the glow larger than the image
                        .opacity(0.4) // Subtle effect
                } placeholder: {
                    Color.clear
                }
                
                
                VStack(alignment: .center, spacing: 3) {
                    
                    AsyncImage(url: URL(string: "\(users[0].serverIP)/Items/\(selectedArtist.id)/Images/Primary?fillHeight=480&fillWidth=480&quality=96&tag=726197babb87ba7515d495fad56d81ed")) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 240, height: 240)
                            .cornerRadius(10)
                    } placeholder: {
                        ProgressView()
                    }
                    
                    VStack(alignment: .center, spacing: 3){
                        Text(selectedArtist.name)
                            .foregroundColor(.primary) 
                            .font(.system(size: 28, weight: .bold))
                            .padding(.top, 10)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 300, alignment: .center)
                        
                       // Text("\(selectedArtist.id)")
                    }
                    Picker("Select List", selection: $selection) {
                                    Text("Albums").tag(0)
                                    Text("Songs").tag(1)
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                .padding()
                                .listRowSeparator(.hidden)
                }
            }
           
            .listRowSeparator(.hidden)
            .frame(maxWidth:.infinity)
            
            Picker("Select List", selection: $selection) {
                            Text("Albums").tag(0)
                            Text("Songs").tag(1)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding()
                        .listRowSeparator(.hidden)
            
            if selection == 0{
                ForEach(Array(artistAlbums.enumerated()), id: \.element.id) { (index, item) in
                    albumView(listedAlbum: item, newUser: users[0])
                }
            }else{
                
                ForEach(Array(artistSongs.enumerated()), id: \.element.id) { (index, item) in
                    Button(action: {
                        MusicPlayer.shared.playSongAndQueue(queueNumber: index, currentUser: users[0], queueList: artistSongs, allAlbums: albums)
                    }) {
                        SongView(listedSong: item, newUser: users[0])
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                        addToQueueButton(currentUser: users[0], songToPlay: item)
                        addToTopQueueButton(songToPlay: item, currentUser: users[0])
                    }
                }
            }
            
            HStack{
                Spacer()
                Image("InAppIcon")
                        .resizable()
                        .frame(width: 100, height: 100)
                Spacer()
            }
        }
        .foregroundColor(Color.black)
        .listStyle(.inset)
       
    }
}

