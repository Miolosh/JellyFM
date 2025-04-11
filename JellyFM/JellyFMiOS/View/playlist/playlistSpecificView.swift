//
//  AlbumSpecificView.swift
//  My Own Mediaplayer
//
//  Created by Toon van der Have on 28/02/2025.
//

import Foundation
import SwiftUI
import SwiftData

struct playlistSpecificView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var songs: [song]
    @Query private var users: [user]
    @Query private var playlists: [playlist]
    @Query private var albums: [album]
    
    @State var playAlbumTapped = false
    @State var playAlbumButtonCollor = Color.white.opacity(0.2)
    @State var addQueueButtonCollor = Color.white.opacity(0.2)
    
    @StateObject private var APICalls:ItemAPI
    
    
    @State var selectedPlaylist: playlist
    @State var songList: [song] = []
    
    init(selectedPlaylist: playlist) {
        _APICalls = StateObject(wrappedValue: ItemAPI())
        self.selectedPlaylist = selectedPlaylist
    }
    
    var body: some View {
        List {
            ZStack{
                AsyncImage(url: URL(string: "\(users[0].serverIP)/Items/\(selectedPlaylist.id)/Images/Primary?fillHeight=480&fillWidth=480&quality=96&tag=726197babb87ba7515d495fad56d81ed")) { image in
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
                    
                    AsyncImage(url: URL(string: "\(users[0].serverIP)/Items/\(selectedPlaylist.id)/Images/Primary?fillHeight=480&fillWidth=480&quality=96&tag=726197babb87ba7515d495fad56d81ed")) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 240, height: 240)
                            .cornerRadius(10)
                    } placeholder: {
                        ProgressView()
                    }
                   
                    
                    VStack(alignment: .center, spacing: 3){
                        Text(selectedPlaylist.name)
                            .foregroundColor(Color.black)
                            .font(.system(size: 28, weight: .bold))
                            .padding(.top, 10)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 300, alignment: .center)
                            
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
                            
                            MusicPlayer.shared.playSongAndQueue(queueNumber: 0, currentUser: users[0], queueList: songList, allAlbums: albums)
                        }){
                            Text("Play playlist")
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
                            
                            for songToAdd in songList{
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
                
            
            ForEach(Array(songList.enumerated()), id: \.element.id) { (index, item) in
                Button(action: {
                    MusicPlayer.shared.playSongAndQueue(queueNumber: index, currentUser: users[0], queueList: songList, allAlbums: albums)
                }) {
                    SongView(listedSong: item, newUser: users[0], withAlbumArt: true)
                        
                }
                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                    Button {
                        MusicPlayer.shared.addSongToQueue(songToPlay: item, currentUser: users[0])
                    } label: {
                        Label("Add to queue", systemImage: "music.note.list")
                    }
                    .tint(.green)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button {
                        APICalls.deleteSongFromPlaylist(currentUser: users[0], playlistId: selectedPlaylist.id, songId: item.id)
                        songList.remove(at: index)
                    } label: {
                        Label("delete", systemImage: "music.note.list")
                    }
                    .tint(.red)
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
        
        
        .onAppear(){
            applyChanges(newSong: selectedPlaylist.songs)
            APICalls.getPlaylistItems(user: users[0], playlistId: selectedPlaylist.id)
        }
        
        .onReceive(APICalls.$songIdsFromPlaylist){newSong in
            applyChanges(newSong: newSong)
        }
        
        
       
    }
    
    private func applyChanges(newSong: [String]){
        
        selectedPlaylist.songs = newSong
        
        let predicate = #Predicate<song> { song in
            newSong.contains(song.id)
        }
                
        do{
            let filteredSongs = try modelContext.fetch(FetchDescriptor<song>(predicate: predicate))
            if filteredSongs.count == 0{
                return
            }
            
            var tempSongs = [] as [song]
            for songId in newSong{
                let songToAdd = filteredSongs.first(where: {$0.id == songId})
                if songToAdd == nil{
                    continue
                }
                tempSongs.append(songToAdd!)
            }
            
            songList = tempSongs
            
            
        }catch{
            print("error")
        }
    
    }
    
    func checkSonglistHasChanged(newSong: [String]) -> Bool{
        var i = 0
        if songList.count > 0 && songList.count == newSong.count{
            for songToCheck in newSong{
                if songToCheck == songList[i].id{
                    i += 1
                    continue
                }else{
                    return true
                }
            }
        }else{
            return true
        }
        return false
    }
}

