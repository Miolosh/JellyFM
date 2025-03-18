//
//  Item.swift
//  My Own Mediaplayer
//
//  Created by Toon van der Have on 13/02/2025.
//

import Foundation
import SwiftData

@Model
final class jellyfinItem {
    
    @Attribute(.unique) var id: String
    var title: String
    var artist: [String]?
    var albumId: String
    var albumArtist: String?
    var indexNumber: Int?
    var dateCreated: Date
    var parentIndexNumber: Int
    var albumArtistId: String?
    var parentId: String?
    
    init(id: String, title: String, artist: [String]?, albumid: String, albumArtist: String?, indexNumber: Int? = nil, dateCreated: String, parentIndexNumber: Int, albumArtistId: String, parrentId: String) {
        self.id = id
        self.title = title
        self.artist = artist
        self.albumId = albumid
        self.albumArtist = albumArtist
        self.indexNumber = indexNumber
        
        let dateFormatter = DateFormatter()

        // Set the date format
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        // Convert the string to a Date object
        if let newDate = dateFormatter.date(from: dateCreated) {
            self.dateCreated = newDate
        } else {
            self.dateCreated = Date.now
        }
        self.parentIndexNumber = parentIndexNumber
        self.albumArtistId = albumArtistId
        self.parentId = parrentId
        print("this parentId = \(parrentId)")
    }
    
}

struct itemsResponse: Codable {
    let items: [APISong]
    
    enum CodingKeys: String, CodingKey {
        case items = "Items"
    }
}

struct APISong: Codable{
    let Id: String
    let Title: String
    let Artists: [String]?
    let albumId: String?
    let albumArtist: String?
    let indexNumber: Int?
    let dateCreated: String
    let ParentIndexNumber: Int?
    let albumArtistObj: [albumArtist]
    let parentId: String?
    
    enum CodingKeys: String, CodingKey {
        case Id = "Id"
        case Title = "Name"
        case Artists = "Artists"
        case albumId = "AlbumId"
        case albumArtist = "AlbumArtist"
        case indexNumber = "IndexNumber"
        case dateCreated = "DateCreated"
        case ParentIndexNumber = "ParentIndexNumber"
        case albumArtistObj = "AlbumArtists"
        case parentId = "ParentId"
    }
}

struct albumArtist: Codable{
    let name: String
    let id: String
    
    enum CodingKeys: String, CodingKey{
        case name = "Name"
        case id = "Id"
    }
}



