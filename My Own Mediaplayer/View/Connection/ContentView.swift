//
//  ContentView.swift
//  My Own Mediaplayer
//
//  Created by Toon van der Have on 08/02/2025.
//

import SwiftUI
import SwiftData


struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [user]
    
    @State private var loginName: String = ""
    @State private var password: String = ""
    @State private var serverURL: String = ""
    
    @State private var serverURLBorderColor = Color.themeTextField //controls the border collor of the textfield host
    @State private var loginBorderColor = Color.themeTextField //controls the border collor of the textfields username and password
    @State private var shakeServer: Bool = false //Controls the shake animation of the textfield for the host
    @State private var shakeLogin: Bool = false //Controls the shake animation of the textfield for the username and password
    
    @StateObject private var viewModel: LoginViewModel
    @StateObject private var songList:ItemAPI
    
    #if os(iOS)
       public let deviceType = "iOS"
    #elseif os(macOS) || targetEnvironment(macCatalyst)
        public let deviceType = "macOS"
   #else
        public let deviceType = "unknown"
   #endif
    
    init() {
        _viewModel = StateObject(wrappedValue: LoginViewModel())
        _songList = StateObject(wrappedValue: ItemAPI())
    }
    
    var body: some View {
            VStack(){
                VStack(spacing: 15) {
                    Spacer()
                    
                    Image("InAppIcon")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                    
                    
                    Text("JellyFM")
                        .font(.largeTitle).foregroundColor(Color.white)
                        .shadow(radius: 10.0, x: 20, y: 10)
                        .multilineTextAlignment(.center)
                        .padding(.trailing, 0)
                    VStack(alignment:.leading){
                        TextField("Host", text: $serverURL)
                            .padding()
                            .background(Color.themeTextField)
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(serverURLBorderColor, lineWidth: 2)
                            )
                            .modifier(Shake(animatableData: CGFloat(shakeServer ? 1 : 0)))
                        if viewModel.serverMistake{
                            Text("The server could not be found")
                                .multilineTextAlignment(.leading)
                                .font(.caption)
                                .foregroundColor(Color.red)
                        }
                        TextField("Username", text: $loginName)
                            .padding()
                            .background(Color.themeTextField)
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(loginBorderColor, lineWidth: 2)
                            )
                            .modifier(Shake(animatableData: CGFloat(shakeLogin ? 1 : 0)))
                        SecureField("Password", text: $password)
                            .padding()
                            .background(Color.themeTextField)
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(loginBorderColor, lineWidth: 2)
                            )
                            .modifier(Shake(animatableData: CGFloat(shakeLogin ? 1 : 0)))
                        if viewModel.loginMistake{
                            Text("Username and or password incorrect")
                                .multilineTextAlignment(.leading)
                                .font(.caption)
                                .foregroundColor(Color.red)
                        }
                        
                        Button(action: {
                            checkServer()
                        }) {
                            Text("Sign In")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(width: 300, height: 50)
                                .background(Color.green)
                                .cornerRadius(15.0)
                                .shadow(radius: 10.0, x: 20, y: 10)
                        }
                        .frame(maxWidth:.infinity)
                        .padding(.top, 30)
                    }
                    Spacer()
                }.padding([.leading, .trailing], 40)
            }
            .background(
                LinearGradient(gradient: Gradient(colors: [.green, .white]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all))
            .onReceive(viewModel.$serverMistake){newState in
                stateChangeServer(newState: newState)
            }
            .onReceive(viewModel.$loginMistake){newState in
                stateChangeLogin(newState: newState)
            }
            .onReceive(viewModel.$lastUser){newState in
                addUser(newState: newState)
            }

    }
    
    func addUser(newState: user?){
        if newState == nil{
            return
        }
        
        let newUser = newState!
        modelContext.insert(newUser)
        songList.checkSongs(searchType: "Audio", user: newUser)
        
        
    }
    
    func stateChangeServer(newState: Bool){
        if newState{
            serverURLBorderColor = Color.red
            triggerShakeAnimation(server: true)
        }else{
            serverURLBorderColor = Color.themeTextField
        }
    }
    
    func stateChangeLogin(newState: Bool){
        if newState{
            loginBorderColor = Color.red
            triggerShakeAnimation(server: false)
        }
        else{
            serverURLBorderColor = Color.themeTextField
        }
    }
    
    private func triggerShakeAnimation(server: Bool) {
        if server{
            withAnimation(.default) {
                shakeServer = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                shakeServer = false
            }
            return
        }
        withAnimation(.default) {
            shakeLogin = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            shakeLogin = false
        }
    }
    
    
    func checkServer(){
        #if os(iOS)
        let deviceID = UIDevice.current.identifierForVendor?.uuidString
        #else
        let deviceID: String? = nil
        #endif
        viewModel.checkServer(usedServerAdress: serverURL, usedUsername: loginName, usedPassword: password, usedDeviceId: deviceID ?? "", deviceType: deviceType)
        
    }
}



struct Shake: GeometryEffect {
    var animatableData: CGFloat
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        return ProjectionTransform(CGAffineTransform(translationX: 6 * sin(animatableData * .pi * 4), y: 0))
    }
}

extension Color {
    static var themeTextField: Color {
        return Color(red: 220.0/255.0, green: 230.0/255.0, blue: 230.0/255.0, opacity: 1.0)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: user.self, inMemory: true)
}


