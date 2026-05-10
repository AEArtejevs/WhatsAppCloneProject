// Simple comments explaining the important parts of the networking layer.
//
//  APIService.swift
//  WhatsAppClone
//
//  Created by Andris on 27/04/2026.
//

import Foundation
// Foundation provides URLSession, URLRequest, JSONEncoder/Decoder, etc.

// Central networking service. Uses a singleton so the app shares one instance.
final class APIService {
    // Singleton instance used throughout the app.
    static let shared = APIService()

    // Base URL of the backend API. Change this when pointing to a real server.
    private let baseURL = "http://localhost:3000"

    // Private to enforce the singleton (prevent others from creating instances).
    private init() {}

    // MARK: - Auth
    // Login, register, and fetch current user endpoints.

    // POST /auth/login — authenticate and get tokens/user info.
    func login(email: String, password: String) async throws -> AuthResponse {
        let body = LoginRequest(
            email: email,
            password: password
        )

        return try await sendRequest(
            endpoint: "/auth/login",
            method: "POST",
            body: body,
            token: nil
        )
    }

    // POST /auth/register — create a new account and get tokens/user info.
    func register(username: String, email: String, password: String) async throws -> AuthResponse {
        let body = RegisterRequest(
            username: username,
            email: email,
            password: password
        )

        return try await sendRequest(
            endpoint: "/auth/register",
            method: "POST",
            body: body,
            token: nil
        )
    }
    
    // GET /auth/me — fetch the current authenticated user using the token.
    func getMe(token: String) async throws -> AuthUser {
        return try await sendRequestWithoutBody(
            endpoint: "/auth/me",
            method: "GET",
            token: token
        )
    }

    // MARK: - Chats
    // List and create chats.

    // GET /chats — fetch all chats for the current user.
    func getChats(token: String) async throws -> [ChatResponse] {
        return try await sendRequestWithoutBody(
            endpoint: "/chats",
            method: "GET",
            token: token
        )
    }

    // MARK: - Messages
    // List and send messages within a chat.

    // GET /chats/{chatId}/messages — load messages for a given chat.
    func getMessages(chatId: Int, token: String) async throws -> [MessageResponse] {
        return try await sendRequestWithoutBody(
            endpoint: "/chats/\(chatId)/messages",
            method: "GET",
            token: token
        )
    }

    // POST /chats/{chatId}/messages — send a message to a chat.
    func sendMessage(chatId: Int, content: String, token: String) async throws -> MessageResponse {
        let body = SendMessageRequest(content: content)

        return try await sendRequest(
            endpoint: "/chats/\(chatId)/messages",
            method: "POST",
            body: body,
            token: token
        )
    }

    // MARK: - Request Helpers
    // Shared helpers to build requests, attach headers, and decode responses.

    // Helper for requests with a JSON body. Adds headers, encodes body, and decodes response.
    private func sendRequest<RequestBody: Encodable, ResponseBody: Decodable>(
        endpoint: String,
        method: String,
        body: RequestBody,
        token: String?
    ) async throws -> ResponseBody {
        // Build the full URL (base + endpoint).
        guard let url = URL(string: baseURL + endpoint) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        // We send/receive JSON.
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Attach Bearer token if provided.
        if let token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // Encode the request body as JSON.
        request.httpBody = try JSONEncoder().encode(body)

        // Perform the network call.
        let (data, response) = try await URLSession.shared.data(for: request)

        return try handleResponse(data: data, response: response)
    }

    // Helper for requests without a body (e.g., simple GET).
    private func sendRequestWithoutBody<ResponseBody: Decodable>(
        endpoint: String,
        method: String,
        token: String?
    ) async throws -> ResponseBody {
        // Build the full URL (base + endpoint).
        guard let url = URL(string: baseURL + endpoint) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        // We send/receive JSON.
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Attach Bearer token if provided.
        if let token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // Perform the network call.
        let (data, response) = try await URLSession.shared.data(for: request)

        return try handleResponse(data: data, response: response)
    }

    // Validate HTTP status and decode JSON into the expected type.
    private func handleResponse<ResponseBody: Decodable>(
        data: Data,
        response: URLResponse
    ) throws -> ResponseBody {
        // Ensure we received an HTTP response.
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        // Treat non-2xx as errors and surface the server message if available.
        guard 200...299 ~= httpResponse.statusCode else {
            let message = String(data: data, encoding: .utf8) ?? "Unknown server error"
            throw APIError.serverError(message)
        }

        // Decode the JSON into the expected response type.
        return try JSONDecoder().decode(ResponseBody.self, from: data)
    }
    
    // GET /users — list users (for starting new chats).
    func getUsers(token: String) async throws -> [ContactResponse] {
        return try await sendRequestWithoutBody(
            endpoint: "/users",
            method: "GET",
            token: token
        )
    }

    // POST /chats/private — create or fetch a private chat with another user.
    func createPrivateChat(otherUserId: Int, token: String) async throws -> ChatResponse {
        let body = CreatePrivateChatRequest(otherUserId: otherUserId)

        return try await sendRequest(
            endpoint: "/chats/private",
            method: "POST",
            body: body,
            token: token
        )
    }
    
    
    
}

// Errors the API layer can throw, with user-friendly descriptions.
enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            // Malformed base URL or endpoint.
            return "Invalid backend URL."
        case .invalidResponse:
            // Response was not HTTP or missing expected parts.
            return "Invalid server response."
        case .serverError(let message):
            // Server sent an error message body.
            return message
        }
    }
}
