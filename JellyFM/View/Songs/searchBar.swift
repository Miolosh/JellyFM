//
//  searchBar.swift
//  JellyFM
//
//  Created by Toon van der Have on 05/04/2025.
//

import SwiftUI

struct searchBar: View {
    @Binding var searchText: String
    
    var body: some View {
        
        
        HStack {
            Image(systemName: "magnifyingglass") // Search icon
                .foregroundColor(.gray) // Icon color
            TextField("", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle()) // Use PlainTextFieldStyle for better layout control
        }
        .padding(8)
        .background(Color(.systemGray6)) // Add background color to mimic search bar style
        .cornerRadius(8) // Rounded corner
        .listRowSeparator(.hidden)
    }
}

#Preview {
    
    @State var text = "Song"
    searchBar(searchText: $text)
}
