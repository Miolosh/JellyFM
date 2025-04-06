//
//  SwiftUIView.swift
//  My Own Mediaplayer
//
//  Created by Toon van der Have on 27/02/2025.
//

import SwiftUI
import SwiftData

struct logOutButton: View {
    
    @StateObject private var viewModel: LoginViewModel
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [user]
    
    
    init() {
        _viewModel = StateObject(wrappedValue: LoginViewModel())
    }
    
    var body: some View {
        Button("Log Out"){
            logOut()
        }
        .foregroundColor(Color.red)
    }
    
    
    
    func logOut() {
        for thisUser in users {
            modelContext.delete(thisUser)
            viewModel.endSession(usedServerAdress: thisUser.serverIP, currentUser: thisUser)
        }
    }
    
}

#Preview {
    //logOutButton()
}
