//
//  JellyFM.swift
//  JellyFM
//
//  Created by Toon van der Have on 08/02/2025.
//

import SwiftUI
import SwiftData

@main
struct My_Own_MediaplayerApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            user.self,
            song.self,
            album.self,
            jellyfinItem.self,
            artist.self,
            playlist.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    @AppStorage("colorMode") private var colorMode: String = "Follow system"
    
    var body: some Scene {
        WindowGroup {
            homePage()
                .preferredColorScheme(colorMode == "Dark" ? .dark : colorMode == "Light" ? .light : nil)
        }
        .modelContainer(sharedModelContainer)
    }
}
