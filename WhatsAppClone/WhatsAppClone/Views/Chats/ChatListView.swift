//
//  ChatListView.swift
//  WhatsAppClone
//
//  Created by Andris on 27/04/2026.
//

import SwiftUI

// Main chat list screen.
// This screen shows existing conversations and lets the user open a chat.
struct ChatListView: View {
    // Shared authentication data, used for the current user and backend token.
    @EnvironmentObject private var authViewModel: AuthViewModel

    // ViewModel that loads chats from the backend.
    @StateObject private var chatListViewModel = ChatListViewModel()

    // Text entered in the search field.
    @State private var searchText: String = ""

    // Stores the chat selected by the user before navigation opens ChatDetailView.
    @State private var selectedChat: ChatResponse? = nil

    // Controls programmatic navigation to the selected chat.
    @State private var shouldOpenChat: Bool = false

    // Filters chats shown in the list.
    // Empty chats are hidden because ContactsView is used to start new conversations.
    private var filteredChats: [ChatResponse] {
        // Only show chats where at least one message exists.
        let chatsWithMessages = chatListViewModel.chats.filter { chat in
            chat.messages.isEmpty == false
        }

        // If search is empty, return all chats that have messages.
        if searchText.isEmpty {
            return chatsWithMessages
        }

        // Search by receiver name or last message text.
        return chatsWithMessages.filter { chat in
            chat.getReceiverName(currentUserId: authViewModel.currentUser?.id)
                .localizedCaseInsensitiveContains(searchText) ||
            chat.getLastMessageText()
                .localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        // NavigationStack allows this screen to open ContactsView and ChatDetailView.
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                VStack(spacing: 0) {
                    // Builds the blue top header with title and logout menu.
                    getHeaderView()
                    // Search field used to filter chats by username or last message.
                    getSearchView()
                    Divider()
                    // Shows loading or error state for the chat list request.
                    getStatusView()
                    // Builds the chat list and supports pull-to-refresh.
                    getChatListView()
                }
                .background(Color("AppBackground"))

                // Floating button used to open ContactsView and start a new chat.
                getFloatingChatButton()
            }
            .onAppear {
                // Load chats when the chat list screen opens.
                chatListViewModel.loadChats(token: authViewModel.token)
            }
            // Opens ChatDetailView after the user taps a chat row.
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
        }
    }

    // MARK: - View Builders

    // Builds the blue top header with title and logout menu.
    @ViewBuilder
    private func getHeaderView() -> some View {
        Header(
            style: .list,
            title: "WhatsApp",
            onLogout: authViewModel.logout
        )
    }

    // Floating button used to open ContactsView and start a new chat.
    @ViewBuilder
    private func getFloatingChatButton() -> some View {
        NavigationLink {
            ContactsView()
                .environmentObject(authViewModel)
        } label: {
            Image(systemName: "message.fill")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(Color.white)
                .frame(width: 58, height: 58)
                .background(Color("AppBlue"))
                .clipShape(Circle())
                .shadow(radius: 6, x: 0, y: 3)
        }
        .padding(.trailing, 20)
        .padding(.bottom, 24)
        .accessibilityLabel("New chat")
    }

    // Search field used to filter chats by username or last message.
    @ViewBuilder
    private func getSearchView() -> some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color("AppTextSecondary"))

            TextField("Search chats", text: $searchText)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .font(.subheadline)
                .submitLabel(.search)

            if searchText.isEmpty == false {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(Color("AppTextSecondary"))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Clear search")
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background(Color("AppSurface"))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color("AppSeparator").opacity(0.35), lineWidth: 0.5)
        )
        .padding(.horizontal, 4)
        .padding(.top, 10)
        .padding(.bottom, 8)
    }

    // Shows loading or error state for the chat list request.
    @ViewBuilder
    private func getStatusView() -> some View {
        if chatListViewModel.isLoading {
            ProgressView("Loading chats...")
                .padding()
        }

        if let errorMessage = chatListViewModel.errorMessage {
            Text(errorMessage)
                .font(.footnote)
                .foregroundStyle(Color("AppDanger"))
                .padding()
        }
    }

    // Builds the chat list and supports pull-to-refresh.
    @ViewBuilder
    private func getChatListView() -> some View {
        List {
            ForEach(filteredChats) { chat in
                // Builds one clickable chat row.
                // Button is used instead of NavigationLink to avoid the default chevron arrow.
                getChatNavigationLink(for: chat)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color("AppBackground"))
        .refreshable {
            // Reload chats when the user pulls down the list.
            chatListViewModel.loadChats(token: authViewModel.token)
        }
    }

    // Builds one clickable chat row.
    // Button is used instead of NavigationLink to avoid the default chevron arrow.
    @ViewBuilder
    private func getChatNavigationLink(for chat: ChatResponse) -> some View {
        Button {
            // Save selected chat, then trigger navigation destination.
            selectedChat = chat
            shouldOpenChat = true
        } label: {
            ChatListItem(
                name: chat.getReceiverName(
                    currentUserId: authViewModel.currentUser?.id
                ),
                messagePreview: chat.getLastMessageText(),
                timeString: chat.getLastMessageTime(),
                unreadCount: 0
            )
        }
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color("AppSurface"))
        .listRowSeparator(.hidden)
    }
 
    
}

#Preview {
    ChatListView()
        .environmentObject(AuthViewModel())
}
