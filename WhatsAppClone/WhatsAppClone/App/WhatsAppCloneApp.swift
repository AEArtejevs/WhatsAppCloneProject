// Simple overview comments added to explain the important parts of the app entry.
//
//  WhatsAppCloneApp.swift
//  WhatsAppClone
//
//  Created by Andris on 27/04/2026.
//

import SwiftUI
// We use SwiftUI's App lifecycle and views.

// App entry point: this struct launches first.
@main
struct WhatsAppCloneApp: App {
    // Single source of truth for authentication state.
    // @StateObject creates and owns the view model for this app scene.
    @StateObject private var authViewModel = AuthViewModel()
    
    // Define the app's window and choose the first screen to show.
    var body: some Scene {
        // Main window container for the app.
        WindowGroup {
            // Decide what to show based on auth state: loading, chats, or login.
            if authViewModel.isLoading {
                ProgressView("Loading...") // Shown while we check/restore session
            }
            // Logged in: go to chat list.
            else if authViewModel.isLoggedIn {
                ChatListView() // Main screen
                    .environmentObject(authViewModel) // Pass auth to child views
            }
            // Not logged in: show login.
            else {
                LoginView() // Sign-in screen
                    .environmentObject(authViewModel) // Pass auth model to login
            }
        }
    }
}
