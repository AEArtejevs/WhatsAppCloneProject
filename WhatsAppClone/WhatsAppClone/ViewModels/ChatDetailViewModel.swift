// Simple comments explaining how chat details and messages are managed.
//
  //  ChatDetailViewModel.swift
//  WhatsAppClone
//
//  Created by Andris on 27/04/2026.
//

import Foundation
import Combine
// Observable view model that loads/sends messages and handles block status.

// Runs on the main actor so published UI updates are safe.
@MainActor
// State and actions for a single chat's detail screen.
final class ChatDetailViewModel: ObservableObject {
    // Messages currently shown in the chat.
    @Published var messages: [MessageResponse] = []
    // Draft text the user is typing.
    @Published var messageText: String = ""

    // True while messages are being loaded.
    @Published var isLoading: Bool = false
    // True while a message is being sent.
    @Published var isSending: Bool = false
    // Error to display in the UI when a request fails.
    @Published var errorMessage: String? = nil
    // Whether the other user is blocked locally.
    @Published var isReceiverBlocked: Bool = false


    // Load all messages for this chat. Requires an auth token.
    func loadMessages(chatId: Int, token: String?) {
        // If there's no token, we can't call the API.
        guard let token else {
            errorMessage = "Missing authentication token."
            return
        }

        // Show a loading indicator and clear old errors.
        isLoading = true
        errorMessage = nil

        Task {
            do {
                // Fetch messages from the server.
                let loadedMessages = try await APIService.shared.getMessages(
                    chatId: chatId,
                    token: token
                )

                // Update state with the latest messages.
                self.messages = loadedMessages
                self.isLoading = false
            } catch {
                // Show a user-friendly error and stop loading.
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }

    // Send the typed message to the server and refresh the list.
    func sendMessage(chatId: Int, token: String?) {
        // Must have a token to send.
        guard let token else {
            errorMessage = "Missing authentication token."
            return
        }

        // Avoid sending empty/whitespace-only messages.
        let trimmedText = messageText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard trimmedText.isEmpty == false else {
            return
        }

        // Indicate sending in progress and clear old errors.
        isSending = true
        errorMessage = nil

        Task {
            do {
                // Call API to send the message.
                _ = try await APIService.shared.sendMessage(
                    chatId: chatId,
                    content: trimmedText,
                    token: token
                )

                // Clear the input field on success.
                self.messageText = ""
                self.isSending = false

                // Reload messages to include the new one.
                self.loadMessages(
                    chatId: chatId,
                    token: token
                )
            } catch {
                // Show error and stop the sending spinner.
                self.errorMessage = error.localizedDescription
                self.isSending = false
            }
        }
    }
    
    // Check if the receiver is blocked in local storage.
    func loadBlockStatus(receiverId: Int?) {
        // If we don't know the receiver yet, default to not blocked.
        guard let receiverId else {
            isReceiverBlocked = false
            return
        }

        isReceiverBlocked = BlockStorage.shared.isUserBlocked(userId: receiverId)
    }

    // Toggle block/unblock for the receiver and update local state.
    func toggleBlockStatus(receiverId: Int?) {
        // Can't toggle without a receiver ID.
        guard let receiverId else {
            return
        }

        if isReceiverBlocked {
            BlockStorage.shared.unblockUser(userId: receiverId)
            isReceiverBlocked = false
        } else {
            BlockStorage.shared.blockUser(userId: receiverId)
            isReceiverBlocked = true
        }
    }
    
    // Background refresh that updates only if there are changes.
    func refreshMessagesSilently(chatId: Int, token: String?) {
        // Skip if we don't have a token.
        guard let token else {
            return
        }

        Task {
            do {
                // Fetch latest messages without touching loading state.
                let loadedMessages = try await APIService.shared.getMessages(
                    chatId: chatId,
                    token: token
                )

                // Update only if message IDs changed to avoid UI flicker.
                if loadedMessages.map({ $0.id }) != messages.map({ $0.id }) {
                    messages = loadedMessages
                }
            } catch {
                // Fail quietly; this is a non-intrusive refresh.
                print("Silent message refresh failed: \(error.localizedDescription)")
            }
        }
    }
    
}

