//
//  playlist.swift
//  JellyFM
//
//  Created by Toon van der Have on 06/04/2025.
//

import Foundation
import SwiftData

@Model
final class playlist{
    
    @Attribute(.unique) var id: String
    var songs: [song] = []
    var name: String = ""
    
    
    init(id: String, name: String){
        self.id = id
        self.name = name
    }
}
