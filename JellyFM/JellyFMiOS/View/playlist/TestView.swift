//
//  TestView.swift
//  JellyFM
//
//  Created by Toon van der Have on 08/04/2025.
//

import SwiftData
import SwiftUI

struct TestView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var playlists: [playlist]
    
    @State var playlistName = ""
    
    
    
    var body: some View {
        Text(playlists[0].name)
        
        
        Button("Change Name") {
                        if !playlists.isEmpty {
                            playlists[0].name = "Test"

                            do {
                                try modelContext.save() // Explicitly save changes
                                playlistName = playlists[0].name // Sync UI with updated value
                            } catch {
                                print("Error saving context: \(error)")
                            }
                        }
                    }
    }
}
