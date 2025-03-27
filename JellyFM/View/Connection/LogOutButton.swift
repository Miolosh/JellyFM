//
//  SwiftUIView.swift
//  My Own Mediaplayer
//
//  Created by Toon van der Have on 27/02/2025.
//

import SwiftUI
import SwiftData

struct logOutButton: View {
    var body: some View {
        Button(action: {
            // Define the action for your button here
            print("Logo Button Tapped")
        }) {
            Image(systemName: "rectangle.portrait.and.arrow.right")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30, height: 30) // Adjust size as needed
        }
    }
}

#Preview {
    logOutButton()
}
