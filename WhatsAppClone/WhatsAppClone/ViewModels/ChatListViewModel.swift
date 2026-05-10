// Simple comments explaining how the chat list is loaded.
//
//  ChatListViewModel.swift
//  WhatsAppClone
//
//  Created by Andris on 27/05/2026.
//

import Foundation
import Combine

// Observable view model for the chat list screen.

// Runs on the main actor so UI-bound state updates are safe.
@MainActor
// Holds chat list state and loads chats from the API.
final class ChatListViewModel: ObservableObject {
    // All chats for the current user.
    @Published var chats: [ChatResponse] = []
    // True while chats are being fetched.
    @Published var isLoading: Bool = false
    // Error message to show when loading fails.
    @Published var errorMessage: String? = nil

    // Fetch the user's chats. Requires a valid auth token.
    func loadChats(token: String?) {
        // If we don't have a token, we can't call the API.
        guard let token else {
            errorMessage = "Missing authentication token."
            return
        }

        // Start loading and clear any previous error.
        isLoading = true
        errorMessage = nil

        Task {
            do {
                // Request chats from the server.
                let loadedChats = try await APIService.shared.getChats(token: token)

                // Update the list on success and stop loading.
                self.chats = loadedChats
                self.isLoading = false
            } catch {
                // Show the error and stop loading.
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
}
