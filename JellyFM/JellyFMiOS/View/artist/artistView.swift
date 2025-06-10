//
//  albumView.swift
//  My Own Mediaplayer
//
//  Created by Toon van der Have on 13/02/2025.
//


import SwiftUI
import SwiftData

struct artistView: View {
    
    @Environment(\.modelContext) private var modelContext
    var currentUser: user
    var listedArtist: artist
    
    
    init(listedArtist: artist, newUser: user) {
        self.listedArtist = listedArtist
        self.currentUser = newUser
        
        
        
    }
    
    var body: some View {
        
        
        NavigationLink(destination: artistSpecificView(selectedArtist: listedArtist)){
            HStack{
                AsyncImage(url: URL(string: "\(currentUser.serverIP)/Items/\(listedArtist.id)/Images/Primary?fillHeight=64&fillWidth=64&quality=96&tag=726197babb87ba7515d495fad56d81ed")) { image in
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
                    Text(listedArtist.name)
                        .foregroundColor(.primary) 
                    
                    
                }
                
            }
            
        }
    }
    

}
