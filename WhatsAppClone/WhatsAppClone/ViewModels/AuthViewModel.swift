// Simple comments explaining how authentication state is managed.
//
//  AuthViewModel.swift
//  WhatsAppClone
//
//  Created by Andris on 27/04/2026.
//

import Foundation
import Combine

// Uses Combine's @Published to notify SwiftUI views about auth changes.
// Runs on the main actor so UI updates are safe.
@MainActor
// Observable view model that holds login status, user, token, and errors.
final class AuthViewModel: ObservableObject {
    // Whether the user is currently authenticated.
    @Published var isLoggedIn: Bool = false
    // The logged-in user's profile (nil if not logged in).
    @Published var currentUser: AuthUser? = nil
    // Auth token used for API calls.
    @Published var token: String? = nil

    // Validation or server error to show in the UI.
    @Published var errorMessage: String? = nil
    // True while a request is in progress (e.g., login, register, restore session).
    @Published var isLoading: Bool = false

    // On startup, try to restore a previous session from stored token.
    init() {
        loadSavedToken()
    }

    // Load token from storage and, if present, fetch the current user.
    func loadSavedToken() {
        // No token saved: ensure logged-out state.
        guard let savedToken = TokenStorage.shared.getToken() else {
            isLoggedIn = false
            currentUser = nil
            token = nil
            return
        }

        // We have a token: tentatively set it and fetch the user.
        token = savedToken
        // Show a loading indicator while verifying the token.
        isLoading = true
        errorMessage = nil

        Task {
            do {
                // Ask the server who this token belongs to.
                let user = try await APIService.shared.getMe(token: savedToken)

                // Token is valid: update state to logged in.
                self.currentUser = user
                self.isLoggedIn = true
                self.isLoading = false
            } catch {
                // Token invalid/expired: clear it and reset to logged out.
                TokenStorage.shared.deleteToken()

                self.token = nil
                self.currentUser = nil
                self.isLoggedIn = false
                self.isLoading = false
            }
        }
    }

    // Validate inputs, call the login API, save token, and update state.
    func login(email: String, password: String) {
        // Basic input validation.
        guard email.isEmpty == false else {
            errorMessage = "Email is required."
            return
        }

        guard password.isEmpty == false else {
            errorMessage = "Password is required."
            return
        }

        // Start loading and clear previous errors.
        isLoading = true
        errorMessage = nil

        Task {
            do {
                // Perform the login request.
                let response = try await APIService.shared.login(
                    email: email,
                    password: password
                )

                // Persist token for future app launches.
                TokenStorage.shared.saveToken(response.token)

                // Update view model with the new session.
                self.token = response.token
                self.currentUser = response.user
                self.isLoggedIn = true
                self.isLoading = false
            } catch {
                // Surface a user-friendly error message.
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }

    // Validate inputs, call the register API, save token, and update state.
    func register(username: String, email: String, password: String, confirmPassword: String) {
        // Basic input validation for all fields.
        guard username.isEmpty == false else {
            errorMessage = "Username is required."
            return
        }

        guard email.isEmpty == false else {
            errorMessage = "Email is required."
            return
        }

        guard password.isEmpty == false else {
            errorMessage = "Password is required."
            return
        }

        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            return
        }

        // Start loading and clear previous errors.
        isLoading = true
        errorMessage = nil

        Task {
            do {
                // Perform the registration request.
                let response = try await APIService.shared.register(
                    username: username,
                    email: email,
                    password: password
                )

                // Persist token for future app launches.
                TokenStorage.shared.saveToken(response.token)

                // Update view model with the new session.
                self.token = response.token
                self.currentUser = response.user
                self.isLoggedIn = true
                self.isLoading = false
            } catch {
                // Surface a user-friendly error message.
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }

    // Clear token and reset all auth-related state.
    func logout() {
        // Remove the stored token from disk.
        TokenStorage.shared.deleteToken()

        token = nil
        currentUser = nil
        isLoggedIn = false
        errorMessage = nil
        isLoading = false
    }
}

