//
//  specificAcknowledgement.swift
//  My Own Mediaplayer
//
//  Created by Toon van der Have on 23/03/2025.
//

import SwiftUI

struct specificAcknowledgement: View {
    
    var acknowledgementText: String
    
    var body: some View {
        ScrollView{
            Text(acknowledgementText)
                .padding()
                .foregroundColor(.black)
                .multilineTextAlignment(.leading)
        }
    }
}

#Preview {
    specificAcknowledgement(acknowledgementText: "hello")
}
