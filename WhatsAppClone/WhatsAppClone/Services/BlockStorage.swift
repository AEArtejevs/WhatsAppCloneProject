// Simple comments explaining how local blocking is stored.
//
//  BlockStorage.swift
//  WhatsAppClone
//
//  Created by Andris on 10/05/2026.
//

import Foundation
// Uses UserDefaults to persist a list of blocked user IDs.

// Small utility for storing blocked users locally (no server involved).
final class BlockStorage {
    // Singleton instance so the app uses one storage helper.
    static let shared = BlockStorage()

    // Key used to save/read the array from UserDefaults.
    private let blockedUsersKey = "blocked_users"

    // Private to enforce the singleton pattern.
    private init() {}

    // Add a user ID to the blocked list (no duplicates).
    func blockUser(userId: Int) {
        // Load current list from UserDefaults.
        var blockedIds = getBlockedUserIds()

        // Append only if it's not already blocked.
        if blockedIds.contains(userId) == false {
            blockedIds.append(userId)
        }

        // Persist the updated list.
        UserDefaults.standard.set(blockedIds, forKey: blockedUsersKey)
    }

    // Remove a user ID from the blocked list.
    func unblockUser(userId: Int) {
        // Filter out the given ID.
        let updatedIds = getBlockedUserIds().filter { $0 != userId }
        // Save the new list.
        UserDefaults.standard.set(updatedIds, forKey: blockedUsersKey)
    }

    // Check if a user ID is currently blocked.
    func isUserBlocked(userId: Int) -> Bool {
        return getBlockedUserIds().contains(userId)
    }

    // Read the array from UserDefaults (or return empty if not set).
    private func getBlockedUserIds() -> [Int] {
        return UserDefaults.standard.array(forKey: blockedUsersKey) as? [Int] ?? []
    }
}
