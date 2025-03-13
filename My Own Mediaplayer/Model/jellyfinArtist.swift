//
//  Item.swift
//  My Own Mediaplayer
//
//  Created by Toon van der Have on 13/02/2025.
//

import Foundation
import SwiftData

@Model
final class jellyFinArtist {
    
    @Attribute(.unique) var id: String
    var name: String
    
    
    init(id: String, name: String) {
        self.id = id
        self.name = name
        
        
    }
    
}

struct artistResponse: Codable {
    let items: [APIArtist]
    
    enum CodingKeys: String, CodingKey {
        case items = "Items"
    }
}

struct APIArtist: Codable{
    let Id: String
    let Name: String
    
    enum CodingKeys: String, CodingKey {
        case Id = "Id"
        case Name = "Name"
        
    }
}



