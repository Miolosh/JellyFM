//
//  File.swift
//  My Own Mediaplayer
//
//  Created by Toon van der Have on 13/02/2025.
//

import Foundation
import SwiftData

@Model
final class toonImage {
    
    var albumId: Int
        @Attribute(.unique) var id: Int
        var title: String
        var url: String
        var thumbnailUrl: String
        @Attribute(.externalStorage) var photo: Data?
        
        init(albumId: Int, id: Int, title: String, url: String, thumbnailUrl: String, photo: Data? = nil) {
            self.albumId = albumId
            self.id = id
            self.title = title
            self.url = url
            self.thumbnailUrl = thumbnailUrl
            self.photo = photo
        }
}
