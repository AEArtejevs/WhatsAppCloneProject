//
//  ContactsViewModel.swift
//  WhatsAppClone
//
//  Created by Andris on 10/05/2026.
//

import Foundation
import Combine

// This ViewModel stores and controls the data used by ContactsView.
// The View should only display data and call these functions.
// The ViewModel handles loading contacts, creating chats, and reporting errors.
@MainActor
final class ContactsViewModel: ObservableObject {
    // List of users that can be shown in the contacts screen.
    @Published var contacts: [ContactResponse] = []

    // When a private chat is created or opened, this value is updated.
    // ContactsView listens to this value and navigates to ChatDetailView.
    @Published var createdChat: ChatResponse? = nil

    // Loading state for fetching contacts from the backend.
    @Published var isLoading: Bool = false

    // Loading state for creating or opening a private chat.
    @Published var isCreatingChat: Bool = false

    // Error message shown in the view if a request fails.
    @Published var errorMessage: String? = nil

    // Loads all users except the currently logged-in user.
    // The token is required because /users is a protected backend route.
    func loadContacts(token: String?) {
        guard let token else {
            errorMessage = "Missing authentication token."
            return
        }

        isLoading = true
        errorMessage = nil

        Task {
            do {
                // Calls APIService, which sends GET /users to the backend.
                let loadedContacts = try await APIService.shared.getUsers(token: token)

                contacts = loadedContacts
                isLoading = false
            } catch {
                // If request fails, store readable error text for the UI.
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }

    // Creates or opens a private chat with the selected contact.
    // If the chat already exists, backend returns the existing chat.
    // If it does not exist, backend creates a new private chat.
    func createPrivateChat(contact: ContactResponse, token: String?) {
        guard let token else {
            errorMessage = "Missing authentication token."
            return
        }

        isCreatingChat = true
        errorMessage = nil

        Task {
            do {
                // Sends POST /chats/private with the selected user's id.
                let chat = try await APIService.shared.createPrivateChat(
                    otherUserId: contact.id,
                    token: token
                )

                // Updating this value tells ContactsView that navigation can happen.
                createdChat = chat
                isCreatingChat = false
            } catch {
                errorMessage = error.localizedDescription
                isCreatingChat = false
            }
        }
    }
}
