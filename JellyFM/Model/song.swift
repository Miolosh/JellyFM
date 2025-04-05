//
//  song.swift
//  My Own Mediaplayer
//
//  Created by Toon van der Have on 09/02/2025.
//

import Foundation
import SwiftData

@Model
final class song {
    
    @Attribute(.unique) var id: String
    var title: String
    var artist: [String]
    var albumId: String
    var trackNumber: Int?
    var indexNumber: Int?
    var discNumber: Int
    var dateCreated: Date
    var premiereDate: Date = Date.now
    
    init(id: String, title: String, artist: [String], albumid: String, trackNumber: Int? = nil, indexNumber: Int? = nil, dateCreated: Date, discNumber: Int, premiereDate: Date) {
        self.id = id
        self.title = title
        self.artist = artist
        self.albumId = albumid
        if trackNumber == nil {
            self.trackNumber = -1
        }else{
            self.trackNumber = trackNumber!
        }
        if indexNumber == nil {
            self.indexNumber = -1
        }else{
            self.indexNumber = indexNumber
        }
        self.dateCreated = dateCreated
        self.discNumber = discNumber
        self.premiereDate = premiereDate
    }
    
}
