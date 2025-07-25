//
//  songView.swift
//  My Own Mediaplayer
//
//  Created by Toon van der Have on 10/02/2025.
//

import SwiftUI
import SwiftData

struct SongView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query private var albums: [album]
    var currentUser: user
    var listedSong: song
    var artists = ""
    var withAlbumArt: Bool = true
    
    @State private var isPlaylistSheetShown = false
    
    @StateObject private var APICalls: ItemAPI
    
    
    
    init(listedSong: song, artists: String = "", newUser: user, withAlbumArt: Bool = true) {
        self.listedSong = listedSong
        self.artists = artists
        self.currentUser = newUser
        self.withAlbumArt = withAlbumArt
        _APICalls = StateObject(wrappedValue: ItemAPI())
        
        
        var i = 1
        
        for artist in listedSong.artist{
            if i == 1{
                self.artists = self.artists  + artist
            }else{
                self.artists = self.artists + ", " + artist
            }
            i += 1
        }
        
    }
    
    var body: some View {
        
        HStack{
            if withAlbumArt{
                AsyncImage(url: MusicPlayer.shared.albumArtUrl(listedSong: listedSong, size: 64)) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    Image("InAppIcon")
                            .resizable()
                            .frame(width: 64, height: 64)
                }
                .frame(width: 48, height: 48)
                .cornerRadius(5)
            
            }else{
                if let indexNumber = listedSong.indexNumber{
                    Text("\(indexNumber).")
                        .padding(.trailing, 10)
                        .foregroundColor(.primary)
                    
                }else{
                    Text("0.")
                        .padding(.trailing, 10)
                        .foregroundColor(.primary) 
                }
            }
            
            VStack(alignment: .leading, spacing: 3){
                Text(listedSong.title)
                    .foregroundColor(.primary)
                
                Text(artists)
                        .font(.subheadline)
                        .foregroundColor(Color.gray)
                
            }
            Spacer()
            Menu {
                Button("Add to playlist") {
                    isPlaylistSheetShown = true
                }
                
            } label: {
                Image(systemName: "ellipsis.circle")
                    .resizable()
                    .frame(width:23, height:23)
                    .foregroundColor(.green)
                
            }

            
        }
        .sheet(isPresented: $isPlaylistSheetShown){
            ChoosePlaylist(song: listedSong)
        }
    }
       
    
    
    
}
