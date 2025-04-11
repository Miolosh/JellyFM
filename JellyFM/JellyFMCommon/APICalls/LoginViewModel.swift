//
//  LoginViewModel.swift
//  JellyFM
//
//  Created by Toon van der Have on 09/02/2025.
//
// API calls are put in a different files and are used to viewcontrollers. This is done to be able to reuse code where possible.
// All swiftData is kept in the views to make the most of the tools we got from Apple.
//

import Foundation
import Alamofire

class LoginViewModel: ObservableObject{

    @Published var serverMistake: Bool = false
    @Published var loginMistake: Bool = false

    @Published var lastUser: user? = nil
    
    let clientName = "JellyFM"
    
    
    public func checkServer(usedServerAdress: String, usedUsername: String, usedPassword: String, usedDeviceId: String, deviceType: String) -> Void{
        
        let systemURL = "\(usedServerAdress)/System/Info/Public"
        
        AF.request(systemURL, method: .get)
            .responseDecodable(of: ServerRespons.self) {response in
                
                switch response.result {
                case .success(_):
                    self.serverMistake = false
                    Task{
                        self.Authenticate(usedServerAdress: usedServerAdress, usedUsername: usedUsername, usedPassword: usedPassword, usedDeviceId: usedDeviceId, deviceType: deviceType)
                    }
                    
                case .failure(_):
                    print("server false")
                    self.serverMistake = true
                }
            }
        
    }
    
    public func Authenticate(usedServerAdress: String, usedUsername: String, usedPassword: String, usedDeviceId: String, deviceType: String) {
        
        let authURL = "\(usedServerAdress)/Users/AuthenticateByName"
        let codings: [String: Any] = [
            "Username": usedUsername,
            "Pw": usedPassword
        ]
        
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"]!
        
        let headers: HTTPHeaders = [
            "Authorization": "MediaBrowser Client='\(clientName)', Device='\(deviceType)', DeviceId='\(usedDeviceId)', Version='\(version!)'"
        ]
        
        AF.request(authURL, method: .post, parameters: codings, encoding: JSONEncoding.default, headers: headers)
            .responseDecodable(of: AuthResponse.self ) {response in
                switch response.result {
                case .success(let value):
                    let newLoggedUser = user(loggingInUsername: value.APIUser.Name, LoggingInToServer: usedServerAdress, currentDeviceID: usedDeviceId, currentDeviceType: deviceType, currentClientVersion: version as! String, token: value.accessToken, currentUserId: value.APIUser.userId)
                    user.currentUser = newLoggedUser
                    self.lastUser = newLoggedUser
                    self.loginMistake = false
                    
                case .failure(_):
                    self.loginMistake = true
                    
                    print("login false")
                }
            }
    }
    
    public func endSession(usedServerAdress: String, currentUser: user){
        let authURL = "\(usedServerAdress)/Sessions/Logout"
        
        
        let headers: HTTPHeaders = [
            "Authorization": "MediaBrowser Token=\(currentUser.token)"
        ]
        
        AF.request(authURL, method: .post, encoding: JSONEncoding.default, headers: headers)
            .response{response in
                switch response.result {
                case .success(_):
                    print("finished")
                    
                case .failure(_):
                    print("could not Logout")
                }
            }
    }
    
}
