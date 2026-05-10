//
//  AuthModels.swift
//  WhatsAppClone
//
//  Created by Andris on 27/04/2026.
//

import Foundation

struct AuthUser: Codable, Identifiable {
    let id: Int
    let username: String
    let email: String
    let createdAt: String
}

struct AuthResponse: Codable {
    let token: String
    let user: AuthUser
}

struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct RegisterRequest: Codable {
    let username: String
    let email: String
    let password: String
}
