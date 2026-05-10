//
//  ChatModels.swift
//  WhatsAppClone
//
//  Created by Andris on 27/04/2026.
//

import Foundation

struct ChatResponse: Codable, Identifiable, Hashable {
    let id: Int
    let isGroup: Bool
    let groupName: String?
    let createdAt: String
    let members: [ChatMemberResponse]
    let messages: [MessageResponse]

    // Gets the receiver user in a private chat.
    // The receiver is the chat member whose id is not the logged-in user's id.
    func getReceiverUser(currentUserId: Int?) -> ChatUserResponse? {
        guard let currentUserId = currentUserId else {
            return nil
        }

        return members.first { member in
            member.user.id != currentUserId
        }?.user
    }

    // Gets the name that should be shown in ChatListView and ChatDetailView header.
    // WhatsApp-style behavior: show the person you are talking to.
    func getReceiverName(currentUserId: Int?) -> String {
        if isGroup {
            return groupName ?? "Group Chat"
        }

        return getReceiverUser(currentUserId: currentUserId)?.username ?? "Unknown User"
    }

    // Gets the latest message preview for the chat list.
    func getLastMessageText() -> String {
        return messages.first?.content ?? "No messages yet"
    }

    // Gets the latest message time for the chat list.
    func getLastMessageTime() -> String {
        return messages.first?.createdAt ?? ""
    }

    static func == (lhs: ChatResponse, rhs: ChatResponse) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct ChatMemberResponse: Codable, Identifiable {
    let id: Int
    let chatId: Int
    let userId: Int
    let createdAt: String
    let user: ChatUserResponse
}

struct ChatUserResponse: Codable, Identifiable {
    let id: Int
    let username: String
    let email: String?
}

struct CreatePrivateChatRequest: Codable {
    let otherUserId: Int
}
