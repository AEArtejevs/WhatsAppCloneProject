//
//  ChatDetailView.swift
//  WhatsAppClone
//
//  Created by Andris on 27/04/2026.
//

import SwiftUI

// Chat detail screen where messages for one selected chat are displayed.
// This view shows the header, message list, blocked-user warning, and message input.
struct ChatDetailView: View {
    // Shared authentication data, used to get the logged-in user and token.
    @EnvironmentObject private var authViewModel: AuthViewModel

    // ViewModel that loads messages, sends messages, and stores block status.
    @StateObject private var chatDetailViewModel = ChatDetailViewModel()

    // Background refresh task used to silently reload messages every second.
    @State private var refreshTask: Task<Void, Never>? = nil
    
    let chat: ChatResponse
    let chatName: String

    // chat contains backend data for the selected conversation.
    // chatName is the name shown in the header, usually the receiver username.

    var body: some View {
        VStack(spacing: 0) {
            getHeaderView()
            getStatusView()
            getMessagesView()
            getMessageInputView()
        }
        .background(Color("AppBackground"))
        .navigationBarBackButtonHidden(true)
        .onAppear {
            // First load messages without showing a loading flicker.
            refreshMessagesSilently()

            // Load local block state for the receiver.
            loadBlockStatus()

            // Start polling so new messages from another simulator appear automatically.
            startMessageRefresh()
        }
        .onDisappear {
            // Stop polling when leaving this screen to avoid unnecessary backend requests.
            stopMessageRefresh()
        }
    }

    // MARK: - View Builders

    // Builds the top chat header with receiver name and block/unblock menu action.
    @ViewBuilder
    private func getHeaderView() -> some View {
        Header(
            style: .detail,
            title: chatName,
            onBlock: {
                toggleBlockStatus()
            },
            blockTitle: getBlockMenuTitle()
        )
    }

    // Shows loading or error text when message requests fail.
    @ViewBuilder
    private func getStatusView() -> some View {
        if chatDetailViewModel.isLoading {
            ProgressView("Loading messages...")
                .padding()
        }

        if let errorMessage = chatDetailViewModel.errorMessage {
            Text(errorMessage)
                .font(.footnote)
                .foregroundStyle(Color("AppDanger"))
                .padding()
        }
    }

    // Shows all messages and places a red blocked-user overlay above them when needed.
    @ViewBuilder
    private func getMessagesView() -> some View {
        ZStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(chatDetailViewModel.messages) { message in
                            getMessageBubbleView(for: message)
                        }
                    }
                    .padding()
                }
                .onAppear {
                    scrollToLastMessage(proxy: proxy)
                }
                .onChange(of: chatDetailViewModel.messages.last?.id) { _, _ in
                    scrollToLastMessage(proxy: proxy)
                }
            }

            if chatDetailViewModel.isReceiverBlocked {
                getBlockedUserOverlay()
            }
        }
    }

    // Builds one message bubble and checks if it belongs to the current logged-in user.
    @ViewBuilder
    private func getMessageBubbleView(for message: MessageResponse) -> some View {
        MessageBubble(
            text: message.content,
            isFromCurrentUser: isMessageFromCurrentUser(message)
        )
        .id(message.id)
    }

    // Red warning card shown over the messages when the receiver is blocked.
    @ViewBuilder
    private func getBlockedUserOverlay() -> some View {
        VStack(spacing: 10) {
            Image(systemName: "nosign")
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(Color.white)

            Text("This user is blocked")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(Color.white)

            Text("To write this user, unblock them first.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.white.opacity(0.9))
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .background(Color("AppDanger"))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(radius: 10, x: 0, y: 4)
        .padding(.horizontal, 28)
    }

    // Shows the input only if the receiver is not blocked.
    @ViewBuilder
    private func getMessageInputView() -> some View {
        if chatDetailViewModel.isReceiverBlocked == false {
            MessageInput(
                messageText: $chatDetailViewModel.messageText,
                isSending: chatDetailViewModel.isSending
            ) {
                sendMessage()
            }
        }
    }

    // MARK: - Helpers

    // Finds the other user's id from chat members.
    private func getReceiverId() -> Int? {
        return chat.getReceiverUser(
            currentUserId: authViewModel.currentUser?.id
        )?.id
    }

    // Changes the header menu title between Block and Unblock.
    private func getBlockMenuTitle() -> String {
        return chatDetailViewModel.isReceiverBlocked ? "Unblock" : "Block"
    }

    // Reads from BlockStorage through the ViewModel to know if the receiver is blocked.
    private func loadBlockStatus() {
        chatDetailViewModel.loadBlockStatus(
            receiverId: getReceiverId()
        )
    }

    // Toggles block/unblock for the receiver.
    private func toggleBlockStatus() {
        chatDetailViewModel.toggleBlockStatus(
            receiverId: getReceiverId()
        )
    }

    // (Old commented-out loadMessages function removed)
    
    // Reloads messages without showing ProgressView, so polling does not visually flicker.
    private func refreshMessagesSilently() {
        chatDetailViewModel.refreshMessagesSilently(
            chatId: chat.id,
            token: authViewModel.token
        )
    }

    // Sends the typed message through the ViewModel.
    private func sendMessage() {
        chatDetailViewModel.sendMessage(
            chatId: chat.id,
            token: authViewModel.token
        )
    }

    // Used to decide if the message bubble should appear as sender or receiver.
    private func isMessageFromCurrentUser(_ message: MessageResponse) -> Bool {
        return message.senderId == authViewModel.currentUser?.id
    }

    // Scrolls to the newest message whenever message list changes.
    private func scrollToLastMessage(proxy: ScrollViewProxy) {
        guard let lastId = chatDetailViewModel.messages.last?.id else {
            return
        }

        withAnimation {
            proxy.scrollTo(lastId, anchor: .bottom)
        }
    }
    
    // Starts simple polling. This is used instead of WebSockets for the MVP.
    private func startMessageRefresh() {
        stopMessageRefresh()

        refreshTask = Task {
            while Task.isCancelled == false {
                try? await Task.sleep(nanoseconds: 1_000_000_000)

                if Task.isCancelled == false {
                    await MainActor.run {
                        refreshMessagesSilently()
                    }
                }
            }
        }
    }

    // Cancels the active polling task.
    private func stopMessageRefresh() {
        refreshTask?.cancel()
        refreshTask = nil
    }
    
}

#Preview {
    NavigationStack {
        ChatDetailView(
            chat: ChatResponse(
                id: 1,
                isGroup: false,
                groupName: nil,
                createdAt: "2026-05-09T20:48:10.255Z",
                members: [],
                messages: []
            ),
            chatName: "Jane Doe"
        )
        .environmentObject(AuthViewModel())
    }
}
