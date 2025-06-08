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
    @Published var songIdsFromPlaylist: [String] = []
    
    @Published var APIShouldBeRecalled = false
    
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
                        
                        let albumArtistObj = currentSong.albumArtistObj ?? []
                        var albumArtist = ""
                        if albumArtistObj.count == 0{
                            albumArtist = "didNotFind"
                        }else{
                            albumArtist = albumArtistObj[0].id
                        }
                        
                        newSong = jellyfinItem(
                            id: currentSong.Id,
                            title: currentSong.Title,
                            artist: currentSong.Artists,
                            albumid: currentSong.albumId ?? "",
                            albumArtist: currentSong.albumArtist ?? "",
                            indexNumber: currentSong.indexNumber,
                            dateCreated: currentSong.dateCreated,
                            parentIndexNumber: currentSong.ParentIndexNumber ?? 1,
                            albumArtistId: albumArtist,
                            parrentId: currentSong.parentId ?? "",
                            premiereDate: currentSong.premiereDate ?? "\(Date.now)")
                        
                        tempSongs.append(newSong ?? jellyfinItem(
                            id: "",
                            title: "",
                            artist: [""],
                            albumid: "",
                            albumArtist: "",
                            indexNumber: currentSong.indexNumber,
                            dateCreated: "2019-08-24T14:15:22Z",
                            parentIndexNumber: 1, albumArtistId: "",
                            parrentId: "0", premiereDate: "\(Date.now)"))
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
    
    public func getPlaylistItems(user: user, playlistId: String){
        var result: [String] = []
        let usedServerAdress = user.serverIP
        
        let headers: HTTPHeaders = [
            "Authorization": "MediaBrowser Token=\(user.token)"
        ]
        
        
        let systemURL = "\(usedServerAdress)/Playlists/\(playlistId)"
        
        AF.request(systemURL, method: .get,  headers: headers)
            .responseDecodable(of: playlistItems.self) {response in
                
                switch response.result {
                case .success(let data):
                    result = data.songIds ?? []
                    self.songIdsFromPlaylist = result
                    break
                case .failure(let error):
                    print(error)
                    print(response)
                    break
                }
                
            }
    }
    
    func deleteSongFromPlaylist(currentUser: user, playlistId: String, songId: String){
        let authURL = "\(currentUser.serverIP)/Playlists/\(playlistId)/Items"
        let codings: [String: Any] = [
            "entryIds": songId
            
        ]
        
        
        let headers: HTTPHeaders = [
            "Authorization": "MediaBrowser Token=\(currentUser.token)"
        ]
        
        AF.request(authURL, method: .delete, parameters: codings, encoding: URLEncoding.default, headers: headers)
            .response { response in
                print("Status code: \(response.response?.statusCode ?? 0)")
                        
                        if let data = response.data, let body = String(data: data, encoding: .utf8) {
                            print("Response body: \(body)")
                        }
                
                if let error = response.error {
                    print("Request failed: \(error)")
                } else {
                    print("Successfully removed song from playlist.")
                }
            }
    }
    
    func addSongToPlaylist(currentUser: user, playlistId: String, songId: String){
        var authURL = "\(currentUser.serverIP)/Playlists/\(playlistId)/Items"
        let codings: [String: Any] = [
            "ids": songId,
            "userId": currentUser.userId
            //Codinsgs does not work in .post. I do not know why, but it does not.
        ]
        
        authURL = authURL + "?ids=\(songId)&userId=\(currentUser.userId)"
        let headers: HTTPHeaders = [
            "Authorization": "MediaBrowser Token=\(currentUser.token)",
            "Content-Type": "application/json"
        ]
        
        AF.request(authURL, method: .post, parameters: codings, encoding: URLEncoding.default, headers: headers)
            .response { response in
                print("Status code: \(response.response?.statusCode ?? 0)")
                        if let data = response.data, let body = String(data: data, encoding: .utf8) {
                            print("Response body: \(body)")
                        }
                
                if let error = response.error {
                    print("Request failed: \(error)")
                } else {
                    print("Successfully added song from playlist.")
                }
            }
    }
    
    func deletePlaylist(playlistId: String, currentUser: user){
        let authURL = "\(currentUser.serverIP)/Items/\(playlistId)"
        let codings: [String: Any] = [
            "entryIds": playlistId
            
        ]
        
        
        let headers: HTTPHeaders = [
            "Authorization": "MediaBrowser Token=\(currentUser.token)"
        ]
        
        AF.request(authURL, method: .delete, parameters: codings, encoding: URLEncoding.default, headers: headers)
            .response { response in
                print("Status code: \(response.response?.statusCode ?? 0)")
                        
                        if let data = response.data, let body = String(data: data, encoding: .utf8) {
                            print("Response body: \(body)")
                        }
                
                if let error = response.error {
                    print("Request failed: \(error)")
                } else {
                    print("Successfully removed song from playlist.")
                }
            }
    }
    
    func addNewPlaylist(currentUser: user){
        APIShouldBeRecalled = false
        let authURL = "\(currentUser.serverIP)/Playlists"
        let codings: [String: Any] = [
            "Ids": ["6666c4779a553b40f3488fab9d0a2170"],
            "IsPublic": false,
            "Name": "TestPlayList",
            "UserId": "\(currentUser.userId)"
        ]
        print(codings)
        
        let headers: HTTPHeaders = [
            "Authorization": "MediaBrowser Token=\(currentUser.token)"
        ]
        
        AF.request(authURL, method: .post, parameters: codings, encoding: JSONEncoding.default, headers: headers)
            .response { response in
                print("Status code: \(response.response?.statusCode ?? 0)")
                        
                        if let data = response.data, let body = String(data: data, encoding: .utf8) {
                            print("Response body: \(body)")
                        }
                
                if let error = response.error {
                    print("Request failed: \(error)")
                } else {
                    print("Successfully removed song from playlist.")
                }
                self.APIShouldBeRecalled = true
                print(self.APIShouldBeRecalled)
            }
    }
    
}
