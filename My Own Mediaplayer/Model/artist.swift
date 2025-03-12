//
//  artist.swift
//  My Own Mediaplayer
//
//  Created by Toon van der Have on 12/03/2025.
//

import Foundation
import SwiftData

@Model
final class artist {
    
    @Attribute(.unique) var id: String
    var title: String
    var artistName: [String]?
    
    init(id: String, title: String, artist: [String]?) {
        self.id = id
        self.title = title
        self.artistName = artist
    }

}


