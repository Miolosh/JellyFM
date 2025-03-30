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
    
    
    func shuffleQueue(player: AVQueuePlayer){
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
            
            /*
             This can be used to get only a partly shuffle.
             A a residual could be kept for when the queue is getting empty
             
             var i = 0
             
             while songsToAddInQueue.count > 0{
             i = Int.random(in: 1...songsToAddInQueue.count)
             newQueueOfSongs.append(songsToAddInQueue[i - 1])
             songsToAddInQueue.remove(at: i - 1)
             }*/
            
            songsToAddInQueue = tempSongs
            isShuffled = true
            currentQueuePosition = 0
            
            newQueueOfSongs = songsToAddInQueue
            
            queueOfSongs = []
             let items = player.items() // Get all items in the queue
             for item in items.dropFirst() { // Skip the first item
                 player.remove(item) // Remove remaining items one by one
             }
            
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
            
            let items = player.items() // Get all items in the queue
            for item in items.dropFirst() { // Skip the first item
                player.remove(item) // Remove remaining items one by one
            }
           
            queueOfSongs = songsToAddInQueue
            currentSongIndex = queueOfSongs.firstIndex(of: currentSong)!
            
            
            
            isShuffled = false
            currentQueuePosition = currentSongIndex
            
        }
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
    
    
}

