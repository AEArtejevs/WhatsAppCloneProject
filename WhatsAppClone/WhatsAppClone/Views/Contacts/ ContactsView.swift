//
//  ContactsView.swift
//  WhatsAppClone
//
//  Created by Andris on 10/05/2026.
//

import SwiftUI
import Combine

// Contacts screen where the logged-in user can choose another user to start a chat.
// This screen loads users from the backend and opens ChatDetailView after a contact is selected.
struct ContactsView: View {
    // Shared authentication data, used for the current user and backend token.
    @EnvironmentObject private var authViewModel: AuthViewModel

    // ViewModel that loads contacts and creates or opens private chats.
    @StateObject private var contactsViewModel = ContactsViewModel()

    // Stores the chat returned by the backend after the user taps a contact.
    @State private var selectedChat: ChatResponse? = nil

    // Controls programmatic navigation to ChatDetailView.
    @State private var shouldOpenChat: Bool = false

    var body: some View {
        // Main vertical layout: header, status messages, and contacts list.
        VStack(spacing: 0) {
            Header(style: .list, title: "Contacts")

            // Shows loading text while contacts are loading and error text if request fails.
            getStatusView()
            // Builds the list of contacts and supports pull-to-refresh.
            getContactsListView()
        }
        .background(Color("AppBackground"))
        .onAppear {
            // Load contacts when the contacts screen opens.
            loadContacts()
        }
        // Opens ChatDetailView after create/open chat request succeeds.
        .navigationDestination(isPresented: $shouldOpenChat) {
            if let selectedChat {
                ChatDetailView(
                    chat: selectedChat,
                    chatName: selectedChat.getReceiverName(
                        currentUserId: authViewModel.currentUser?.id
                    )
                )
            }
        }
        // Listens for createdChat changes from the ViewModel.
        // When backend returns a chat, this triggers navigation.
        .onReceive(contactsViewModel.$createdChat.compactMap { $0 }) { newChat in
            selectedChat = newChat
            shouldOpenChat = true
        }
    }

    // MARK: - View Builders

    @ViewBuilder
    private func getStatusView() -> some View {
        if contactsViewModel.isLoading {
            ProgressView("Loading contacts...")
                .padding()
        }

        if let errorMessage = contactsViewModel.errorMessage {
            Text(errorMessage)
                .font(.footnote)
                .foregroundStyle(Color("AppDanger"))
                .padding()
        }
    }

    @ViewBuilder
    private func getContactsListView() -> some View {
        List {
            ForEach(contactsViewModel.contacts) { contact in
                // Each contact row is a button.
                // Tapping it asks the backend to create or open a private chat.
                Button {
                    openChat(with: contact)
                } label: {
                    ContactListItem(contact: contact)
                }
                .buttonStyle(.plain)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color("AppSurface"))
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color("AppBackground"))
        .refreshable {
            // Reload contacts when the user pulls down the list.
            loadContacts()
        }
    }

    // MARK: - Helpers

    // Calls the ViewModel to fetch contacts from GET /users.
    private func loadContacts() {
        contactsViewModel.loadContacts(token: authViewModel.token)
    }

    // Calls the ViewModel to create or open a private chat with the selected contact.
    private func openChat(with contact: ContactResponse) {
        contactsViewModel.createPrivateChat(
            contact: contact,
            token: authViewModel.token
        )
    }
}

#Preview {
    NavigationStack {
        ContactsView()
            .environmentObject(AuthViewModel())
    }
}
