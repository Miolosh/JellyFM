//
//  albumView.swift
//  My Own Mediaplayer
//
//  Created by Toon van der Have on 13/02/2025.
//


import SwiftUI
import SwiftData

struct albumViewTile: View {
    
    @Environment(\.modelContext) private var modelContext
    var currentUser: user
    var listedAlbum: album
    var artists = ""
    
    
    init(listedAlbum: album, artists: String = "", newUser: user) {
        self.listedAlbum = listedAlbum
        self.artists = listedAlbum.albumArtist ?? ""
        self.currentUser = newUser
        
        
        
    }
    
    var body: some View {
        
        
        NavigationLink(destination: AlbumSpecificView(selectedAlbum: listedAlbum)) {
            VStack(alignment: .leading){
                AsyncImage(url: URL(string: "\(currentUser.serverIP)/Items/\(listedAlbum.id)/Images/Primary?fillHeight=480&fillWidth=480&quality=96&tag=726197babb87ba7515d495fad56d81ed")) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    ProgressView()
                }
                .cornerRadius(5)
                .frame(width: 150, height: 150)
                VStack(alignment:.leading){
                    Text(listedAlbum.title)
                        .multilineTextAlignment(.leading)
                        .lineLimit(1)
                    Text(artists)
                        .font(.subheadline)
                        .foregroundColor(Color.gray)
                        .lineLimit(1)
                }
                
            }
        }
        .buttonStyle(PlainButtonStyle())
        .frame(width:150, height:180)
        
    }
    

}
