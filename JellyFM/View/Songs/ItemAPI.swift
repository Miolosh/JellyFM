//
//  ItemAPI.swift
//  My Own Mediaplayer
//
//  Created by Toon van der Have on 09/02/2025.
//192.168.0.80:8097/api-docs/swagger

import Foundation

import Alamofire

class ItemAPI: ObservableObject{
    
    @Published var songs = [jellyfinItem]()
    @Published var lastUpdated = Date() //indicates the whole reload has been started (first function)
    @Published var artists = [jellyFinArtist]()
    
    let amountOfLoadsAtSameTime = 50
    @Published var currentPosition = 0
    let sortBy = "Title"
    @Published var lastIncrement = Date() //indicate the increment (second function is used)
    
    //Songs and albums
    
    public func checkSongs(searchType: String, user: user) -> Void{
        currentPosition = 0
        if (searchType == "artist"){
            increaseArtists(user: user)
        }else{
            increaseLoadedSongs(searchType: searchType, user: user)
        }
    }
    
    public func increaseLoadedSongs(searchType: String, user: user){
        songs = [jellyfinItem]()
        
        //Returns the songs of music
        let systemURL = decideOnUrl(user: user, searchType: searchType)
        
        let headers: HTTPHeaders = [
            "Authorization": "MediaBrowser Token=\(user.token)"
        ]
        
        var newSong: jellyfinItem?
        var tempSongs = [jellyfinItem]()
        
        
        AF.request(systemURL, method: .get,  headers: headers)
            .responseDecodable(of: itemsResponse.self) {response in
                
                switch response.result {
                case .success(let data):
                    if data.items.count == 0{
                        return
                    }
                    for currentSong in data.items {
                        print(currentSong.parentId)
                        newSong = jellyfinItem(id: currentSong.Id, title: currentSong.Title, artist: currentSong.Artists, albumid: currentSong.albumId ?? "", albumArtist: currentSong.albumArtist ?? "", indexNumber: currentSong.indexNumber, dateCreated: currentSong.dateCreated, parentIndexNumber: currentSong.ParentIndexNumber ?? 1, albumArtistId: currentSong.albumArtistObj[0].id ?? "", parrentId: currentSong.parentId ?? "")
                        tempSongs.append(newSong ?? jellyfinItem(id: "", title: "", artist: [""], albumid: "", albumArtist: "", indexNumber: currentSong.indexNumber, dateCreated: "2019-08-24T14:15:22Z", parentIndexNumber: 1, albumArtistId: "", parrentId: "0"))
                        print(newSong?.parentId)
                    }
                    
                    self.currentPosition = self.currentPosition + self.amountOfLoadsAtSameTime
                    self.songs = tempSongs
                    if(self.currentPosition == self.amountOfLoadsAtSameTime){
                        self.lastUpdated = Date()
                    }else{
                        self.lastIncrement = Date()
                    }
                    break
                    
                case .failure(let error):
                    print(error)
                    print(response)
                    break
                }
            }
    }
    
    func decideOnUrl(user: user, searchType: String) -> String{
        let usedServerAdress = user.serverIP
        var systemURL = ""
        
        if searchType != "artist"{
            systemURL = "\(usedServerAdress)/Items?UserId=\(user.userId)&SortBy=\(sortBy)%2CSortName&SortOrder=Ascending&IncludeItemTypes=\(searchType)&Recursive=true&Fields=ParentId&Fields=DateCreated&StartIndex=\(currentPosition)&ImageTypeLimit=1&EnableImageTypes=Primary&Limit=\(amountOfLoadsAtSameTime)"
        }
        else{
            systemURL = "\(usedServerAdress)/Artists/AlbumArtists?SortBy=SortName&SortOrder=Ascending&Recursive=true&Fields=PrimaryImageAspectRatio%2CSortName&StartIndex=\(currentPosition)&ImageTypeLimit=1&EnableImageTypes=Primary%2CBackdrop%2CBanner%2CThumb&Limit=\(amountOfLoadsAtSameTime)"
        }
        
        return systemURL
        
    }
    
    //Artists
    public func increaseArtists(user: user){
        songs = [jellyfinItem]()
        let searchType = "artist"
        
        //Returns the songs of music
        let systemURL = decideOnUrl(user: user, searchType: searchType)
        
        let headers: HTTPHeaders = [
            "Authorization": "MediaBrowser Token=\(user.token)"
        ]
        
        var newItem: jellyFinArtist?
        var tempSongs = [jellyFinArtist]()
        
        
        AF.request(systemURL, method: .get,  headers: headers)
            .responseDecodable(of: artistResponse.self) {response in
                
                switch response.result {
                case .success(let data):
                    if data.items.count == 0{
                        return
                    }
                    for currentSong in data.items {
                        newItem = jellyFinArtist(id: currentSong.Id, name: currentSong.Name)
                        tempSongs.append(newItem ?? jellyFinArtist(id: "", name: ""))
                    }
                    
                    
                    self.currentPosition = self.currentPosition + self.amountOfLoadsAtSameTime
                    self.artists = tempSongs
                    if(self.currentPosition == self.amountOfLoadsAtSameTime){
                        self.lastUpdated = Date()
                    }else{
                        self.lastIncrement = Date()
                    }
                    break
                    
                case .failure(let error):
                    print(error)
                    print(response)
                    break
                }
            }
    }
    
}
