//
//  albumLastAddedHorizontal.swift
//  My Own Mediaplayer
//
//  Created by Toon van der Have on 05/03/2025.
//

import SwiftUI

struct albumLastAddedHorizontal: View {
    var albums: [album]
    var currentUser: user
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHGrid(rows: [GridItem(.fixed(150))], spacing: 16) {
                ForEach(albums.sorted { $0.dateCreated > $1.dateCreated }.prefix(15)) { listedAlbum in
                    albumViewTile(listedAlbum: listedAlbum, newUser: currentUser)
                }
            }
            .frame(height: 200)
            .padding(.horizontal)
        }
    }
}

#Preview {
    albumLastAddedHorizontal(albums: [], currentUser: user(loggingInUsername: "miolosh", LoggingInToServer: "1010", currentDeviceID: "AAL", currentDeviceType: "This", currentClientVersion: "TEST", token: "TEST", currentUserId: "TEST"))
}
