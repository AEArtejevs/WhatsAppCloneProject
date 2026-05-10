//
//  TokenStorage.swift
//  WhatsAppClone
//
//  Created by Andris on 09/05/2026.
//

import Foundation

final class TokenStorage {
    static let shared = TokenStorage()

    private let tokenKey = "auth_token"

    private init() {}

    func saveToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: tokenKey)
    }

    func getToken() -> String? {
        return UserDefaults.standard.string(forKey: tokenKey)
    }

    func deleteToken() {
        UserDefaults.standard.removeObject(forKey: tokenKey)
    }
}
