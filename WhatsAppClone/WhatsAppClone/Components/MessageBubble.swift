//
//  MessageBubbleView.swift
//  WhatsAppClone
//
//  Created by Andris on 27/04/2026.
//

import SwiftUI

struct MessageBubble: View {
    let text: String
    let isFromCurrentUser: Bool

    var body: some View {
        HStack {
            if isFromCurrentUser {
                Spacer()
            }

            Text(text)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(isFromCurrentUser ? Color.appBlueBubble : Color.appPinkBubble)
                .foregroundStyle(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))

            if isFromCurrentUser == false {
                Spacer()
            }
        }
    }
}

#Preview {
    VStack {
        MessageBubble(text: "Receiver message", isFromCurrentUser: false)
        MessageBubble(text: "Sender message", isFromCurrentUser: true)
    }
    .padding()
}
