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
    @Query private var albums: [album]
    
    @State var playAlbumTapped = false
    @State var playAlbumButtonCollor = Color.white.opacity(0.2)
    @State var addQueueButtonCollor = Color.white.opacity(0.2)
    
    
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
                    
                    HStack{
                        Button(action: {
                            playAlbumTapped = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                                playAlbumTapped = false
                            }
                            let impact = UIImpactFeedbackGenerator(style: .medium)
                            impact.impactOccurred()
                            
                            withAnimation(.easeInOut(duration: 0.1)) { // Smooth transition over 1 second
                                playAlbumButtonCollor = playAlbumButtonCollor == Color.white.opacity(0.2) ? Color.white.opacity(0.5) : Color.white.opacity(0.2)
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // Delay reset after animation
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    playAlbumButtonCollor = playAlbumButtonCollor == Color.white.opacity(0.2) ? Color.white.opacity(0.5) : Color.white.opacity(0.2)
                                }
                            }
                            
                            MusicPlayer.shared.playSongAndQueue(queueNumber: 0, currentUser: users[0], queueList: albumSongs, allAlbums: albums)
                        }){
                            Text("Play album")
                                .frame(width:150, height: 60)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .background(playAlbumButtonCollor)
                        .cornerRadius(15)
                        .padding(5)
                        
                        
                        Button(action: {
                            let impact = UIImpactFeedbackGenerator(style: .medium)
                            impact.impactOccurred()
                            
                            withAnimation(.easeInOut(duration: 0.1)) { // Smooth transition over 1 second
                                addQueueButtonCollor = addQueueButtonCollor == Color.white.opacity(0.2) ? Color.white.opacity(0.5) : Color.white.opacity(0.2)
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // Delay reset after animation
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    addQueueButtonCollor = addQueueButtonCollor == Color.white.opacity(0.2) ? Color.white.opacity(0.5) : Color.white.opacity(0.2)
                                }
                            }
                            
                            for songToAdd in albumSongs{
                                MusicPlayer.shared.addSongToQueue(songToPlay: songToAdd, currentUser: users[0])
                            }
                            
                            
                            
                        }){
                            Text("Add to queue")
                                .frame(width:150, height: 60)
                            
                        }
                        .buttonStyle(PlainButtonStyle())
                        .background(addQueueButtonCollor)
                        .cornerRadius(15)
                        .padding(5)
                        
                    }
                    .padding(20)
                   
                }
                
                
            }
           
            .listRowSeparator(.hidden)
            .frame(maxWidth:.infinity)
                
            
            ForEach(Array(albumSongs.enumerated()), id: \.element.id) { (index, item) in
                Button(action: {
                    MusicPlayer.shared.playSongAndQueue(queueNumber: index, currentUser: users[0], queueList: albumSongs, allAlbums: albums)
                }) {
                    SongView(listedSong: item, newUser: users[0], withAlbumArt: false)
                }
                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                    addToQueueButton(currentUser: users[0], songToPlay: item)
                    addToTopQueueButton(songToPlay: item, currentUser: users[0])
                }
            }
            HStack{
                Spacer()
                Image("InAppIcon")
                        .resizable()
                        .frame(width: 100, height: 100)
                Spacer()
            }
            .frame(height: 150)
            .listRowSeparator(.hidden)
        }
        .foregroundColor(Color.black)
        .listStyle(.inset)
       
    }
}

