//
//  MessageModels.swift
//  WhatsAppClone
//
//  Created by Andris on 10/05/2026.
//

import Foundation

struct MessageResponse: Codable, Identifiable {

    let id: Int
    let chatId: Int
    let senderId: Int
    let receiverId: Int
    let content: String
    let messageType: String
    let status: String
    let createdAt: String
    let sender: MessageUserResponse?
    let receiver: MessageUserResponse?

}

struct MessageUserResponse: Codable, Identifiable {

    let id: Int
    let username: String
    let email: String

}

struct SendMessageRequest: Codable {
    
    let content: String
}
