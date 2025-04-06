//
//  MusicTimeLine.swift
//  My Own Mediaplayer
//
//  Created by Toon van der Have on 09/03/2025.
//

import SwiftUI
import AVFoundation

struct MusicTimeLine: View {
    @ObservedObject var musicPlayer = MusicPlayer.shared
    @State var currentTime: Double = 0
    @State var currentSongDuration: Double = 0
    @State var isDragging: Bool = false
    
    
    var body: some View {
        HStack{
            Text(getElapsedTimeString())
                .frame(width: 50)
            Spacer()
            SliderView1(value: $currentTime, maxValue: $currentSongDuration, isDragging: $isDragging)
                .frame( height:10)
            
            Spacer()
            Text(getFullTime())
                .frame(width: 50)
        }.onAppear {
            addPeriodicTimeObserver()
        }
    }
    
    func getElapsedTimeString() -> String{
        
        var totalSeconds = floor(musicPlayer.player.currentTime().seconds)
        
        if isDragging{
            totalSeconds = currentTime
        }
        if totalSeconds.isNaN{
            return "NaN"
        }
        let minutes = Int(totalSeconds) / 60
        let seconds = Int(totalSeconds) % 60
        
        if seconds < 10 {
            return "\(minutes):0\(seconds)"
        }
        
        return "\(minutes):\(seconds)"
    }
    
    func getFullTime() -> String{
        let total = musicPlayer.player.currentItem?.duration.seconds ?? -1
        if total < 0{
            return "NAN"
        }else if total.isNaN{
            return "NAN"
        }
        
        let totalSeconds = floor(musicPlayer.player.currentItem?.duration.seconds ?? 1.0)
        let minutes = Int(totalSeconds) / 60
        let seconds = Int(totalSeconds) % 60
        
        if seconds < 10 {
            return "\(minutes):0\(seconds)"
        }
        
        return "\(minutes):\(seconds)"
    }
    
    func addPeriodicTimeObserver() {
            let timeInterval = CMTime(seconds: 1.0, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            musicPlayer.player.addPeriodicTimeObserver(forInterval: timeInterval, queue: .main) { time in
                if !isDragging{
                    currentTime = time.seconds
                    currentSongDuration = floor(musicPlayer.player.currentItem?.duration.seconds ?? 0)
                }
            }
        }
    
}

struct SliderView1: View {
    @Binding var value: Double
    @Binding var maxValue: Double
    @Binding var isDragging: Bool
    
    @State var lastCoordinateValue: CGFloat = 0.0
    @State var sliderLength: CGFloat = 0.0
    
    var sliding = false
    
    var body: some View {
        GeometryReader { gr in
            let thumbSize = gr.size.height * 0.8
            let radius = gr.size.height * 0.5
            let minValue = gr.size.width * 0.015
            let maxValue = sliderLength - thumbSize - 1.0
            
            ZStack {
                GeometryReader{ geometry in
                    RoundedRectangle(cornerRadius: radius)
                        .foregroundColor(.white)
                        .onAppear{
                            sliderLength = geometry.size.width
                        }
                }
                
                HStack {
                    Circle()
                        .foregroundColor(Color.green)
                        .frame(width: thumbSize, height: thumbSize)
                        .offset(x: min(max(self.value / self.maxValue * sliderLength - thumbSize, minValue),maxValue))
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { v in
                                    if abs(v.translation.width) < 0.1 {
                                        self.lastCoordinateValue = self.value
                                    }
                                    let newValue = self.lastCoordinateValue + v.translation.width / sliderLength * self.maxValue
                                    self.value = min(max(newValue, 0), self.maxValue) // Clamp the value to the valid range
                                    isDragging = true
                                }
                                .onEnded { _ in
                                    let targetTime = CMTime(seconds: self.value, preferredTimescale: 1)
                                    MusicPlayer.shared.player.seek(to: targetTime)
                                    isDragging = false
                                }
                        )
                    Spacer()
                }
            }
        }
    }
}


#Preview {
    MusicTimeLine()
}
