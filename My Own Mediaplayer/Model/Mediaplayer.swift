//
//  Mediaplayer.swift
//  My Own Mediaplayer
//
//  Created by Toon van der Have on 16/02/2025.
//
import AVKit
import MediaPlayer
import SwiftUI
import SwiftData

//The musicplayer is not in the model, making it initiate each time
//this is currently by design :)
class MusicPlayer: ObservableObject {
    
    @Environment(\.modelContext) private var modelContext
    
    static let shared = MusicPlayer()
    
    var player: AVQueuePlayer = AVQueuePlayer()
    var currentQueuePosition = 0
    var playlistEnded = false
    var activeUser: user?
    var timeObserverToken: Any?
    var currentUrl: String?
    var currentTitle: String?
    
    @Published var queueOfSongs: [song] = []
    @Published var currentArtistString: String = ""
    @Published var isPlaying: Bool = false
    @Published var isRepeatingSong: Bool = false
    
    var albums: [album]?

    private init() {
        setupRemoteTransportControls()
        #if os(iOS)
        player.allowsExternalPlayback = false
        configureAudioSession()
        #endif
    }

    
    //this function is called by views. It deletes the full queue and starts a new one. (clicking on a song)
    func playSongAndQueue(queueNumber: Int, currentUser: user, queueList: [song], allAlbums: [album]){
        MusicPlayer.shared.startNewQueue(songToPlay: queueList[queueNumber], currentUser: currentUser)
        self.albums = allAlbums
        if queueNumber + 1 >= queueList.count {
            return
        }
        
        for i in queueNumber + 1...queueList.count - 1{
            MusicPlayer.shared.addSongToQueue(songToPlay: queueList[i], currentUser: currentUser)
        }
        
        
    }
    
    //This function is to be called by views; This adds a song to the existing queue.
    func addSongToQueue(songToPlay: song, currentUser: user){
        if player.items().count == 0{
            startNewQueue(songToPlay: songToPlay, currentUser: currentUser)
        }else{
            addSingleSongToQueue(songToPlay: songToPlay, currentUser: currentUser)
        }
        
        
    }
    
    //Function used to play one song
    private func startNewQueue(songToPlay: song, currentUser: user){
        activeUser = currentUser
        player.removeAllItems()
        queueOfSongs = []
        currentQueuePosition = 0
        
        addSingleSongToQueue(songToPlay: songToPlay, currentUser: currentUser)
        
        player.play()
        isPlaying = true
        playlistEnded = false
        addPeriodicTimeObserver()
        createArtistString(currentSong: queueOfSongs[0])
        updateNowPlayingInfo()
        
    }
    
    
    private func addSingleSongToQueue(songToPlay: song, currentUser: user, addQueueData: Bool = true){
        let songId = songToPlay.id
        
        //FLAC and wave are not included as containers to make sure the stream is encoded to MP3.
        //Besides, FLACs will not be able to be played due to apple. Seeking will break if using FLAC.
        //This is an issue in all jellyfin clients (even the official webplayer).
        
        let url = createUrl(songId: songId, currentUser: currentUser)!
        
        let playerItem = AVPlayerItem(url: url)
        
        
        if addQueueData{
            queueOfSongs.append(songToPlay)
        }
        
        
        player.insert(playerItem, after: player.items().last)
        
    }
    
    
    func createArtistString(currentSong: song){
        currentArtistString = ""
        for (index, artist) in (currentSong.artist).enumerated() {
            if index > 0 {
                currentArtistString += ", "
            }
            currentArtistString += artist
        }
    }

    

    func togglePlayPause() {
        if player.timeControlStatus == .playing {
            player.pause()
            isPlaying = false
        } else {
            if playlistEnded {
                player.seek(to: .zero)
                playlistEnded = false
            }
            player.play()
            isPlaying = true
        }
    }


    func stop() {
        player.pause()
        //player = nil
        removePeriodicTimeObserver()
    }

    func setupRemoteTransportControls() {
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.addTarget { [unowned self] event in
            if player.rate == 0.0 {
                player.play()
                return .success
            }
            return .commandFailed
        }

        commandCenter.pauseCommand.addTarget { [unowned self] event in
            if player.rate == 1.0 {
                player.pause()
                return .success
            }
            return .commandFailed
        }

        commandCenter.nextTrackCommand.isEnabled = true
        commandCenter.nextTrackCommand.addTarget { [unowned self] event in
                playNextTrack()
                return .success
            }
        
        commandCenter.previousTrackCommand.isEnabled = true
        commandCenter.previousTrackCommand.addTarget { [unowned self] event in
                playPreviousTrack()
                return .success
            }

        commandCenter.changePlaybackPositionCommand.isEnabled = true
        commandCenter.changePlaybackPositionCommand.addTarget { [unowned self] event in
            guard let positionEvent = event as? MPChangePlaybackPositionCommandEvent else {
                return .commandFailed
            }
            let positionTime = CMTime(seconds: positionEvent.positionTime, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            player.seek(to: positionTime, toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] finished in
                    if finished {
                        self?.updateNowPlayingInfo() // Ensure the now playing info is updated after seeking
                    }
                }
            return .success
        }
    }

    func updateNowPlayingInfo() {
        
        //print(getStreamedDataSize(player: player))
        //Check if currentsong == currentQueuePosition. Important for automatic move forward of songs if previous song ended.
        var i = 0
        let maxValueI = 300
        while currentQueuePosition < queueOfSongs.count - 1 && !checkIfSame(currentSongUrl: createUrl(songId: queueOfSongs[currentQueuePosition].id, currentUser: activeUser!), newSongUrl: getCurrentSongUrl()) && i <= maxValueI{
            currentQueuePosition += 1
            createArtistString(currentSong: queueOfSongs[currentQueuePosition])
            i += 1
        }
        
        //safefail if currentposition would be behind the real song.
        if currentQueuePosition >= queueOfSongs.count{
            currentQueuePosition = 0
        }
        
        var nowPlayingInfo = [String: Any]()
        var title = ""
        var artist = ""
        var albumName = "Album not found"
        
        
        
        //make sure the user knows the mediaplayer is searching for the right info
        if maxValueI <= i{
            title = "Searching..."
            artist = "Searching..."
            albumName = "Searching..."
        }else{
            title = queueOfSongs[currentQueuePosition].title
            artist = currentArtistString
            let albumId = queueOfSongs[currentQueuePosition].albumId
            if let filteredAlbums = albums?.filter { $0.id == albumId}{
                if filteredAlbums.count > 0{
                    albumName = filteredAlbums[0].title
                }
            }
            
        }
        
        currentTitle = title
        currentArtistString = artist
        
        nowPlayingInfo[MPMediaItemPropertyTitle] = title
        nowPlayingInfo[MPMediaItemPropertyArtist] = artist
        
        nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = albumName

        let imageURL = albumArtUrl(listedSong: queueOfSongs[currentQueuePosition], size: 248)!
#if os(iOS)
        downloadImage(from: imageURL) { image in
            if let image = image {
                let artwork = MPMediaItemArtwork(boundsSize: image.size) { size in
                    return image
                }
                nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
            }
            
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = self.player.currentTime().seconds
            nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = self.player.currentItem?.duration.seconds
            nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = self.player.rate
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        }
        
        if isRepeatingSong {
            if let currentItemDuration = self.player.currentItem?.duration.seconds {
                if (currentItemDuration - self.player.currentTime().seconds) <= 0.99 {
                    player.seek(to: .zero)
                }
            }
        }

        
        #endif

    }

#if os(iOS)
    func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else {
                completion(nil)
                return
            }
            completion(image)
        }
        task.resume()
    }
    #endif

    func addPeriodicTimeObserver() {
        let player = player
        
        let timeInterval = CMTime(seconds: 1.0, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: timeInterval, queue: .main) { [weak self] time in
            self?.updateNowPlayingInfo()
            
        }
    }

    func removePeriodicTimeObserver() {
        if let timeObserverToken = timeObserverToken {
            player.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }
    
    func getStreamedDataSize(player: AVPlayer) -> Int64 {
        guard let accessLog = player.currentItem?.accessLog() else { return 0 }
        
        let totalBytes = accessLog.events.reduce(0) { sum, event in
            sum + event.numberOfBytesTransferred
        }
        
        return totalBytes
    }
    
    func playNextTrack() {
        if player.items().count > 1 {
            player.advanceToNextItem()
            currentQueuePosition += 1
            createArtistString(currentSong: queueOfSongs[currentQueuePosition])
            updateNowPlayingInfo()
            player.seek(to: .zero)
        } else {
            guard let currentItem = player.currentItem else { return }
                
            let duration = currentItem.duration
            let endTime = CMTime(seconds: duration.seconds - 0.1, preferredTimescale: duration.timescale) // Seek to slightly before the end

            player.seek(to: endTime) { finished in
                if finished {
                    print("✅ Seeked to end of song")
                }
            }
        }
    }
    
    func moveBackInQueue(){
        let allItems = player.items()
        player.removeAllItems()
        if currentQueuePosition > 0{
            currentQueuePosition -= 1
        }
        
        //add the previous song back to the queue
        addSingleSongToQueue(songToPlay: queueOfSongs[currentQueuePosition], currentUser: activeUser!, addQueueData: false)
        
        
        for allItem in allItems {
            player.insert(allItem, after: player.items().last)
        }
        player.play()
        createArtistString(currentSong: queueOfSongs[currentQueuePosition])
    }
    
    func playPreviousTrack() {
        let currentTime = player.currentTime().seconds

        if currentTime > 3 {
            // If more than 3 seconds have passed, restart the song
            player.seek(to: .zero)
        } else {
            moveBackInQueue()
            updateNowPlayingInfo()
        }
    }
    
#if os(iOS)
    private func configureAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback,
                                         mode: .default,
                                         policy: .longFormAudio)
            try audioSession.setActive(true)
            
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }
    #endif
    
    
    
    func getCurrentSongUrl() -> URL?{
        if let currentItem = player.currentItem {
            if let asset = currentItem.asset as? AVURLAsset {
                return asset.url
            }
        }
        return nil
    }
    
    func checkIfSame(currentSongUrl: URL?, newSongUrl: URL?) -> Bool{
        if currentSongUrl == nil || newSongUrl == nil{
            return false
        }
        return currentSongUrl!.absoluteString == newSongUrl!.absoluteString
    }
    
    func createUrl(songId: String, currentUser: user) -> URL?{
        let MaxStreamingBitsize = readKbpsStream() * 1000
        //print(MaxStreamingBitsize)
        return URL(string:
                    "\(currentUser.serverIP)/Audio/\(songId)/universal?UserId=\(currentUser.userId)&DeviceId=\(currentUser.deviceID)&MaxStreamingBitrate=\(MaxStreamingBitsize)&Container=ts%7Cmp3%2Cmp3%2Caac%2Cm4a%7Caac%2Cm4b%7Caac%2Cflac%2Calac%2Cm4a%7Calac%2Cm4b%7Calac%2Cwebma%2Cwebm%7Cwebma%2Cwav%2Cmp4%7Copus&TranscodingContainer=mp4&TranscodingProtocol=hls&AudioCodec=aac&api_key=\(currentUser.token)&StartTimeTicks=0&EnableRedirection=true&EnableRemoteMedia=false&EnableAudioVbrEncoding=true")
    }
    
    func albumArtUrl(listedSong: song, size:Int) ->URL?{
        return URL(string:"\(activeUser?.serverIP ?? "")/Items/\(listedSong.albumId)/Images/Primary?fillHeight=\(size)&fillWidth=\(size)&quality=96&tag=726197babb87ba7515d495fad56d81ed")
    }
    
    func readKbpsStream() -> Int{
        var streamCount = UserDefaults.standard.integer(forKey: "streamSpeed")
        // Returns 0 if the key does not exist
        if streamCount == 0{
            streamCount = 320000
            changeKbpsStream(amount: streamCount)
        }
        return streamCount/1000
    }
    
    func changeKbpsStream(amount: Int){
        UserDefaults.standard.set(amount, forKey: "streamSpeed")
    }
}
