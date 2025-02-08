//
//  user.swift
//  My Own Mediaplayer
//
//  Created by Toon van der Have on 08/02/2025.
//

import Foundation
import SwiftData

@Model
final class user {
    static var currentUser: user = user(loggingInUsername: "noUser", LoggingInToServer: "0.0.0.0", currentDeviceID: "NoDeviceId", currentDeviceType: "noType", currentClientVersion: "0", token: "0", currentUserId: "")
    
    var deviceID: String
    var deviceType: String
    var clientVersion: String
    var serverIP: String
    var username: String
    var token: String
    var currentUser: Bool
    
    @Attribute(.unique) var userId: String //Keep in mind that if CloudKit would be used, the unique function is unusable and will break the kit.
    
    init(loggingInUsername: String, LoggingInToServer: String, currentDeviceID: String, currentDeviceType: String, currentClientVersion: String, token: String, currentUserId: String) {
        username = loggingInUsername
        serverIP = LoggingInToServer
        deviceID = currentDeviceID
        deviceType = currentDeviceType
        clientVersion = currentClientVersion
        userId = currentUserId
        self.token = token
        currentUser = true
    }
}

struct APIUser: Codable{
    let Name: String
    let ServerId: String
    let userId: String
    
    enum CodingKeys: String, CodingKey {
        case Name = "Name"
        case ServerId = "ServerId"
        case userId = "Id"
    }
}

struct AuthResponse: Codable {
    let accessToken: String
    let APIUser: APIUser
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "AccessToken"
        case APIUser = "User"
    }
}

struct ServerRespons: Codable {
    let LocalAddress: String
    let ServerName: String
    let Version: String
    let ProductName: String
    let Id: String
    
    enum CodingKeys: String, CodingKey {
        case LocalAddress = "LocalAddress"
        case ServerName = "ServerName"
        case Version = "Version"
        case ProductName = "ProductName"
        case Id = "Id"
    }
}
