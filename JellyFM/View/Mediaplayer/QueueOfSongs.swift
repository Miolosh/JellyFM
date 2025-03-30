//
//  QueueOfSongs.swift
//  My Own Mediaplayer
//
//  Created by Toon van der Have on 11/03/2025.
//

import SwiftUI
import SwiftData

struct QueueOfSongs: View {
    
    @Environment(\.modelContext) private var modelContext
    @StateObject var musicPlayer = MusicPlayer.shared
    
    @State var i = 0
    @State var isPreviousSongsExapnded = false
    
    var body: some View {
        
        NavigationView{
            List {
                
                Section(){
                    Text("Now playing")
                        .listRowSeparator(.hidden)
                        .font(.headline)
                    SongView(listedSong: musicPlayer.queue.queueOfSongs[musicPlayer.queue.currentQueuePosition],newUser: musicPlayer.activeUser!)
               
                    
                        
                }
                
                if musicPlayer.queue.currentQueuePosition > 0{
                    Section(){
                        DisclosureGroup( isExpanded: $isPreviousSongsExapnded){
                            ForEach (musicPlayer.queue.queueOfSongs.indices){ index in
                                if musicPlayer.queue.currentQueuePosition > index{
                                    SongView(listedSong: musicPlayer.queue.queueOfSongs[index],newUser: musicPlayer.activeUser!)
                                }
                            }
                        }label: {
                            Text("Previous played songs")
                                .font(.headline)
                                .listRowSeparator(.hidden)
                        }
                    }
                }
                
                
                
                Section(){
                    Text("Upcomming songs")
                        .font(.headline)
                        .listRowSeparator(.hidden)
                    ForEach (musicPlayer.queue.queueOfSongs.indices){ index in
                        if musicPlayer.queue.currentQueuePosition < index{
                            SongView(listedSong: musicPlayer.queue.queueOfSongs[index],newUser: musicPlayer.activeUser!)
                        }
                    }
                    
                        
                }
            }.listStyle(GroupedListStyle())
                .navigationTitle("Queue")
        }
    }
}

#Preview {
    QueueOfSongs()
}
