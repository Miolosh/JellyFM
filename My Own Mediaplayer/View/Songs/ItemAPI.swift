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
    
    let amountOfLoadsAtSameTime = 10
    @Published var currentPosition = 0
    let sortBy = "Title"
    @Published var lastIncrement = Date() //indicate the increment (second function is used)
    
    
    public func checkSongs(searchType: String, user: user) -> Void{
        
        songs = [jellyfinItem]()
        currentPosition = 0
        
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
                    
                    print(systemURL)
                    for currentSong in data.items {
                        newSong = jellyfinItem(id: currentSong.Id, title: currentSong.Title, artist: currentSong.Artists, albumid: currentSong.albumId ?? "", albumArtist: currentSong.albumArtist ?? "", indexNumber: currentSong.indexNumber, dateCreated: currentSong.dateCreated, parentIndexNumber: currentSong.ParentIndexNumber ?? 1)
                        tempSongs.append(newSong ?? jellyfinItem(id: "", title: "", artist: [""], albumid: "", albumArtist: "", indexNumber: currentSong.indexNumber, dateCreated: "2019-08-24T14:15:22Z", parentIndexNumber: 1))
                    }
                    
                    self.currentPosition = self.currentPosition + self.amountOfLoadsAtSameTime
                    self.songs = tempSongs
                    self.lastUpdated = Date()
                    break
                    
                case .failure(let error):
                    print(error)
                    print(response)
                    break
                }
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
                    print(systemURL)
                    if data.items.count == 0{
                        return
                    }
                    for currentSong in data.items {
                        newSong = jellyfinItem(id: currentSong.Id, title: currentSong.Title, artist: currentSong.Artists, albumid: currentSong.albumId ?? "", albumArtist: currentSong.albumArtist ?? "", indexNumber: currentSong.indexNumber, dateCreated: currentSong.dateCreated, parentIndexNumber: currentSong.ParentIndexNumber ?? 1)
                        tempSongs.append(newSong ?? jellyfinItem(id: "", title: "", artist: [""], albumid: "", albumArtist: "", indexNumber: currentSong.indexNumber, dateCreated: "2019-08-24T14:15:22Z", parentIndexNumber: 1))
                    }
                    
                    self.currentPosition = self.currentPosition + self.amountOfLoadsAtSameTime
                    self.songs = tempSongs
                    self.lastIncrement = Date()
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
        
        
        let systemURL = "\(usedServerAdress)/Items?UserId=\(user.userId)&SortBy=\(sortBy)%2CSortName&SortOrder=Ascending&IncludeItemTypes=\(searchType)&Recursive=true&Fields=ParentId&Fields=DateCreated&StartIndex=\(currentPosition)&ImageTypeLimit=1&EnableImageTypes=Primary&Limit=\(amountOfLoadsAtSameTime)"
        
        
        return systemURL
        
    }
}
