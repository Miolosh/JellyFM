//
//  MediaController.swift
//  My Own Mediaplayer
//
//  Created by Toon van der Have on 18/02/2025.
//

import SwiftUI
import AVKit
import SwiftData


struct BottomPlayerView: View{
    @Environment(\.modelContext) private var modelContext
    @ObservedObject var musicPlayer = MusicPlayer.shared
    
    @State var isFullScreenMediaplayerActive = false
    
    var body: some View {
        if musicPlayer.player.currentItem != nil {
        
            VStack{
                Divider()
                    .background(Color.green)
                HStack(){
                    let currentlyPlayingSong = musicPlayer.queue.queueOfSongs[musicPlayer.queue.currentQueuePosition]
                        AsyncImage(url: URL(string: "\(musicPlayer.activeUser?.serverIP ?? "")/Items/\(currentlyPlayingSong.albumId)/Images/Primary?fillHeight=64&fillWidth=64&quality=96&tag=726197babb87ba7515d495fad56d81ed")) { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 48, height: 48)
                    
                    
                    VStack(alignment: .leading, spacing: 3){
                        Text(musicPlayer.currentTitle ?? "")
                        
                        
                        Text(musicPlayer.currentArtistString)
                            .font(.subheadline)
                            .foregroundColor(Color.gray)
                        
                    }
                    Spacer()
                    Button(action: {
                        musicPlayer.requestPreviousTrack()
                    }) {
                        Image(systemName: "backward.fill")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(Color.black)
                    }
                    .padding()
                    Button(action: {
                                            musicPlayer.togglePlayPause()
                    }) {
                        Image(systemName: musicPlayer.isPlaying ? "pause.fill" : "play.fill")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(Color.black)
                    }
                    .padding()
                    Button(action: {
                        musicPlayer.playNextTrack()
                    }) {
                        Image(systemName: "forward.fill")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(Color.black)
            
                    }
                    .padding()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            } .background(Color.white)
                .shadow(color: Color.black.opacity(0.2), radius: 8, x:0, y: 4)
                .onTapGesture{
                    self.isFullScreenMediaplayerActive.toggle()
                }
            #if os(iOS)
                .fullScreenCover(isPresented: $isFullScreenMediaplayerActive){
                    MediaplayerViewFull()
                        .edgesIgnoringSafeArea(.all)
                        .gesture(
                            DragGesture()
                                .onEnded { value in
                                    if value.translation.height > 100 {
                                        isFullScreenMediaplayerActive = false
                                    }
                                }
                            
                        )
                }
#endif
        }
        
    }

    
    
}

#Preview {
    BottomPlayerView()
}
