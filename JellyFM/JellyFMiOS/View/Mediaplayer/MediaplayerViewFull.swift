//
//  MediaplayerViewFull.swift
//  My Own Mediaplayer
//
//  Created by Toon van der Have on 07/03/2025.
//

import SwiftUI
import SwiftData
import AVKit

struct MediaplayerViewFull: View {
    @Environment(\.modelContext) private var modelContext
    @ObservedObject var musicPlayer = MusicPlayer.shared
    
    @State var QueueShown: Bool = false
        
    var body: some View {
        
        ZStack {
            let currentlyPlayingSong = musicPlayer.queue.queueOfSongs[musicPlayer.queue.currentQueuePosition]
            // Background overlay
            AsyncImage(url: URL(string: "\(musicPlayer.activeUser?.serverIP ?? "")/Items/\(currentlyPlayingSong.albumId)/Images/Primary?fillHeight=480&fillWidth=480&quality=96&tag=726197babb87ba7515d495fad56d81ed")) { image in
                image
                    .resizable()
                    .blur(radius: 100) // Create a soft glow
                    .scaleEffect(1.5) // Make the glow larger than the image
                    .opacity(0.4) // Subtle effect
            } placeholder: {
                Color.clear
            }
            .edgesIgnoringSafeArea(.all) // Ensure the overlay covers the entire screen
            VStack{
                HStack(alignment: .top){
                    Spacer()
                    AirPlayButton()
                        .frame(width: 44, height: 44)
                    //.padding(.trailing, 20)
                }
                .padding(.top, 50)
                .padding(.trailing, 15)
                Spacer()
            }
            
            VStack{
                Spacer()
                VStack(alignment: .center, spacing: 3){
                    Text(musicPlayer.currentTitle ?? "")
                        .foregroundColor(Color.black)
                        .font(.system(size: 28, weight: .bold))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 300, alignment: .center)
                    
                    
                    Text(musicPlayer.currentArtistString)
                        .foregroundColor(Color.black)
                        .font(.system(size: 24))
                        .padding(.bottom, 30)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 300, alignment: .center)
                    
                    let currentlyPlayingSong = musicPlayer.queue.queueOfSongs[musicPlayer.queue.currentQueuePosition]
                    AsyncImage(url: URL(string: "\(musicPlayer.activeUser?.serverIP ?? "")/Items/\(currentlyPlayingSong.albumId)/Images/Primary?fillHeight=480&fillWidth=480&quality=96&tag=726197babb87ba7515d495fad56d81ed")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 240, height: 240)
                            .cornerRadius(10)
                            .padding(.bottom, 50)
                    } placeholder: {
                        ProgressView()
                    }
                    
                    
                    MusicTimeLine()
                    HStack{
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
                    HStack{
                        Button(action: {
                            musicPlayer.shuffleQueue()
                        }) {
                            Image(systemName: "shuffle")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(musicPlayer.queue.isShuffled ? .green : .black)
                        }
                        .padding()
                        Button(action: {
                            musicPlayer.isRepeatingSong.toggle()
                        }) {
                            Image(systemName: "repeat.1")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(musicPlayer.isRepeatingSong ? .green : .black)
                        }
                        .padding()
                        Button(action: {
                            QueueShown.toggle()
                        }) {
                            Image(systemName: "list.bullet")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.black)
                        }
                        .padding()
                    }
                    
                }
                Spacer()
                
            }
            
            .padding()
            
            
        }.sheet(isPresented: $QueueShown){
            QueueOfSongs()
        }
        
    }
    
}

struct AirPlayButton: UIViewRepresentable {
    func makeUIView(context: Context) -> AVRoutePickerView {
        let airPlayButton = AVRoutePickerView()
        airPlayButton.activeTintColor = .blue
        airPlayButton.tintColor = .gray
        return airPlayButton
    }

    func updateUIView(_ uiView: AVRoutePickerView, context: Context) {}
}

#Preview {
    MediaplayerViewFull()
}
