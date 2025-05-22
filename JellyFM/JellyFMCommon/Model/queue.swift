//
//  queue.swift
//  JellyFM
//
//  Created by Toon van der Have on 30/03/2025.
//

import AVKit
import MediaPlayer
import SwiftUI
import SwiftData

class queueObject: ObservableObject{
    
    @Published var queueOfSongs: [song] = []
    @Published var isShuffled: Bool = false
    
    var currentQueuePosition = 0
    var originalQueueWithoutShuffle: [song] = []
    
   
    
    func startNewQueue(newQueue: [song]){
        queueOfSongs = newQueue
        currentQueuePosition = 0
        
        isShuffled = false
    }
    
    func addSongsToQueue(songsToAdd: [song]){
        queueOfSongs = queueOfSongs + songsToAdd
    }
    
    
    func shuffleQueue(currentMusicPlayer: MusicPlayer){
        if queueOfSongs.count == 0{
            return print("Queue of songs is empty and cannot be shuffled")
        }
        
        var songsToAddInQueue: [song] = []
        var newQueueOfSongs: [song] = []
        var currentSongIndex: Int = 0
        
        
        if !isShuffled{
            let currentSong = queueOfSongs[currentQueuePosition]
            var tempSongs = queueOfSongs
            tempSongs.remove(at: currentQueuePosition)
            tempSongs.shuffle()
            originalQueueWithoutShuffle = queueOfSongs
            newQueueOfSongs = []
            
            songsToAddInQueue = tempSongs
            isShuffled = true
            currentQueuePosition = 0
            
            newQueueOfSongs = songsToAddInQueue
            
            queueOfSongs = []
            currentMusicPlayer.deleteAllItemsExceptCurrentPlay()
            
            for newSongOfQueue in newQueueOfSongs {
                //addSongToQueue(songToPlay: newQueueOfSong, currentUser: activeUser!)
                queueOfSongs.append(newSongOfQueue)
            }
            
            queueOfSongs = [currentSong] + queueOfSongs
            
        }else{
            if originalQueueWithoutShuffle == []{return isShuffled = false}
            
            let currentSong = queueOfSongs[currentQueuePosition]
            songsToAddInQueue = originalQueueWithoutShuffle
            originalQueueWithoutShuffle = []
            
            currentMusicPlayer.deleteAllItemsExceptCurrentPlay()
           
            queueOfSongs = songsToAddInQueue
            currentSongIndex = queueOfSongs.firstIndex(of: currentSong)!
            
            
            
            isShuffled = false
            currentQueuePosition = currentSongIndex
            
        }
    }
    
    func addSongToTopOfQueue(songToAdd: song, currentUser: user){
        if queueOfSongs.count < 0 {
            startNewQueue(newQueue: [songToAdd])
            MusicPlayer.shared.addSongToQueue(songToPlay: songToAdd, currentUser: currentUser)
            return
        }
        let tempQueue = queueOfSongs
        var newQueue: [song] = []
        
        let firstPart = tempQueue.prefix(currentQueuePosition + 1)
        let howManyLast = queueOfSongs.count - currentQueuePosition - 1
        let lastPart = tempQueue.suffix(howManyLast)
        
        newQueue = firstPart + [songToAdd] + lastPart
        queueOfSongs = newQueue
        MusicPlayer.shared.deleteAllItemsExceptCurrentPlay()
    }
    
    func deleteSongFromQueue(at index: Int) -> Void{
        queueOfSongs.remove(at: index)
        MusicPlayer.shared.deleteAllItemsExceptCurrentPlay()
    }
    
    func returnCurrentSong() -> song{
        return queueOfSongs[currentQueuePosition]
    }
    
    
    func getNextItems(from: Int, to: Int = 1) -> [song]{
        var nextSongs: [song] = []
        for i in currentQueuePosition + from ... currentQueuePosition + to{
            if i >= queueOfSongs.count{
                return nextSongs
            }
            nextSongs.append(queueOfSongs[i])
        }
        
        return nextSongs
    }
    
    func advanceInQueue() -> Void{
        currentQueuePosition += 1
        
        if currentQueuePosition > queueOfSongs.count - 1 {
            print("position of queue was too large")
            return
        }
        return
    }
    
    
}

