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
    var name: String
    
    init(id: String, name: String) {
        self.id = id
        self.name = name
    }

}


