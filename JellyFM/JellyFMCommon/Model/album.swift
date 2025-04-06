//
//  album.swift
//  My Own Mediaplayer
//
//  Created by Toon van der Have on 13/02/2025.
//

import Foundation
import SwiftData

@Model
final class album {
    
    @Attribute(.unique) var id: String
    var title: String
    var artist: [String]
    var albumId: String
    var albumArtist: String?
    var albumArtistId: String?
    var dateCreated: Date
    var parentId: String?
    var premiereDate: Date = Date.now
    
    init(id: String, title: String, artist: [String], albumid: String, albumArtist: String?, dateCreated: Date, albumArtistId: String?, parentId: String? = nil, premiereDate: Date) {
        self.id = id
        self.title = title
        self.artist = artist
        self.albumId = albumid
        self.albumArtist = albumArtist
        self.dateCreated = dateCreated
        self.albumArtistId = albumArtistId
        self.parentId = parentId
        self.premiereDate = premiereDate
    }

}


