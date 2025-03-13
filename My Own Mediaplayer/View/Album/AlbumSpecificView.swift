//
//  AlbumSpecificView.swift
//  My Own Mediaplayer
//
//  Created by Toon van der Have on 28/02/2025.
//

import SwiftUI
import SwiftData

struct AlbumSpecificView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var songs: [song]
    @Query private var users: [user]
    
    
    var albumSongs: [song] {
        
        return songs
            .filter { $0.albumId == selectedAlbum.id }
            .sorted {
                if $0.discNumber == $1.discNumber {
                    return $0.indexNumber ?? 0 < $1.indexNumber ?? 0
                }
                return $0.discNumber < $1.discNumber
            }
        
    }
    
    var selectedAlbum: album
    
    var body: some View {
        List {
            ZStack{
                AsyncImage(url: URL(string: "\(users[0].serverIP)/Items/\(selectedAlbum.id)/Images/Primary?fillHeight=480&fillWidth=480&quality=96&tag=726197babb87ba7515d495fad56d81ed")) { image in
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
                    
                    AsyncImage(url: URL(string: "\(users[0].serverIP)/Items/\(selectedAlbum.id)/Images/Primary?fillHeight=480&fillWidth=480&quality=96&tag=726197babb87ba7515d495fad56d81ed")) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 240, height: 240)
                            .cornerRadius(10)
                    } placeholder: {
                        ProgressView()
                    }
                    
                    VStack(alignment: .center, spacing: 3){
                        Text(selectedAlbum.title)
                            .foregroundColor(Color.black)
                            .font(.system(size: 28, weight: .bold))
                            .padding(.top, 10)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 300, alignment: .center)
                            
                        
                        
                        Text(selectedAlbum.albumArtist ?? "")
                            .font(.subheadline)
                            .foregroundColor(Color.gray)
                    }
                }
            }
           
            .listRowSeparator(.hidden)
            .frame(maxWidth:.infinity)
            
            ForEach(Array(albumSongs.enumerated()), id: \.element.id) { (index, item) in
                Button(action: {
                    MusicPlayer.shared.playSongAndQueue(queueNumber: index, currentUser: users[0], queueList: albumSongs)
                }) {
                    SongView(listedSong: item, newUser: users[0], withAlbumArt: false)
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
            VStack{
                Image("InAppIcon")
                        .resizable()
                        .frame(width: 100, height: 100)
            }
            .frame(height: 150)
        }
        .foregroundColor(Color.black)
        .listStyle(.inset)
       
    }
}

