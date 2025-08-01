//
//  settingsView.swift
//  My Own Mediaplayer
//
//  Created by Toon van der Have on 11/03/2025.
//

import SwiftUI
import SwiftData

struct settingsView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [user]
    
    @State var streamingSpeed: Int = MusicPlayer.shared.readKbpsStream()*1000
    
    enum ColorMode: String, CaseIterable {
        case system = "Follow system"
        case light = "Light"
        case dark = "Dark"
    }
    
    @AppStorage("colorMode") private var colorMode: String = "system"
    
    var body: some View {
        NavigationView{
            VStack{
                List{
                    Section(footer:Text("Keep in mind changing the streamingspeed will also change the quality of the audio. Changes may not take effect immediatly after changing the value.")){
                        
                        Picker("Select Theme", selection: $colorMode) {
                            ForEach(ColorMode.allCases, id: \.self) { mode in
                                Text(mode.rawValue).tag(mode.rawValue)
                            }
                        }
                        
                        Picker("Streamingspeed", selection: $streamingSpeed) {
                            Text("320 Kbps").tag(320000)
                            Text("256 Kbps").tag(256000)
                            Text("128 Kbps").tag(128000)
                            
                        }
                        .pickerStyle(MenuPickerStyle())
                        .onChange(of: streamingSpeed) {
                            MusicPlayer.shared.changeKbpsStream(amount: streamingSpeed)
                        }
                        
                    }
                    Section{
                        NavigationLink{
                            Acknowledgements()
                        }label:{
                            Text("Acknowledgements")
                        }
                    }
                    Section{
                        logOutButton()
                    }
                    
                    Section{
                        HStack{
                            Spacer()
                            Text("This application was created by Toon van der Have")
                                .font(.footnote) // Set the font size to footnote
                                .foregroundColor(.gray) // Set the text color to gray
                                .padding(.top, 8) // Add some padding on top
                                .multilineTextAlignment(.center)
                            Spacer()
                        }
                    }.listRowBackground(Color(UIColor.systemGroupedBackground))
                }
                
            }.navigationTitle("Settings")
            .preferredColorScheme(colorMode == "Dark" ? .dark : colorMode == "Light" ? .light : nil)
    
        }
    }
    
    
    func logOut() {
        for thisUser in users {
            modelContext.delete(thisUser)
        }
    }
}

#Preview {
    settingsView()
}
