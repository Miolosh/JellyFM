//
//  albumView.swift
//  My Own Mediaplayer
//
//  Created by Toon van der Have on 13/02/2025.
//


import SwiftUI
import SwiftData

struct playlistView: View {
    
    @Environment(\.modelContext) private var modelContext
    var currentUser: user
    var listedPlaylist: playlist
    
    
    init(listedPlaylist: playlist, newUser: user) {
        self.listedPlaylist = listedPlaylist
        self.currentUser = newUser
        
        
        
    }
    
    var body: some View {
        
        
        NavigationLink(destination: playlistSpecificView(selectedPlaylist: listedPlaylist)) {
            HStack{
                AsyncImage(url: URL(string: "\(currentUser.serverIP)/Items/\(listedPlaylist.id)/Images/Primary?fillHeight=64&fillWidth=64&quality=96&tag=726197babb87ba7515d495fad56d81ed")) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    Image("InAppIcon")
                            .resizable()
                            .frame(width: 64, height: 64)
                }
                .cornerRadius(5)
                .frame(width: 48, height: 48)
                VStack(alignment: .leading, spacing: 3){
                    Text(listedPlaylist.name)
                    
                    
                }
                
            }
        }
        
    }
    

}
