//
//  buttons.swift
//  JellyFM
//
//  Created by Toon van der Have on 22/05/2025.
//

import SwiftUI

struct addToQueueButton: View {
    
    var currentUser: user
    var songToPlay: song
    
    init(currentUser: user, songToPlay: song) {
        self.currentUser = currentUser
        self.songToPlay = songToPlay
    }
    
    var body: some View {
        Button {
            MusicPlayer.shared.addSongToQueue(songToPlay: songToPlay, currentUser: currentUser)
        } label: {
            Label("Add to queue", systemImage: "text.line.last.and.arrowtriangle.forward")
        }
        .tint(.green)
    }
}

struct addToTopQueueButton: View{
    
    var songToPlay: song
    var currentUser: user
    
    init(songToPlay: song, currentUser: user) {
        self.songToPlay = songToPlay
        self.currentUser = currentUser
    }
    
    var body: some View {
        Button {
            MusicPlayer.shared.queue.addSongToTopOfQueue(songToAdd: songToPlay, currentUser: currentUser)
        } label: {
            Label("Add to next", systemImage: "text.line.first.and.arrowtriangle.forward")
        }
        .tint(.yellow)
    }
}
