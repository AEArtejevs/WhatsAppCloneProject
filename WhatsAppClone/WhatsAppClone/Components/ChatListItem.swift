//
//  ChatListItem.swift
//  WhatsAppClone
//
//  Created by Andris on 27/04/2026.
//

import SwiftUI


struct ChatListItem: View {
    // Sample placeholders; in a real app, these would be passed in as props
    var name: String = "John Doe"
    var messagePreview: String = "Hey! Are we still on for tonight?"
    var timeString: String = "10:30 AM"
    var unreadCount: Int = 2

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 43, height: 43)

                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 44, height: 44)
                    .foregroundStyle(Color("AppBlue"))
            }
            // Text content
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline) {
                    Text(name)
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))
                        .lineLimit(1)

                    Spacer(minLength: 8)

                    Text(timeString)
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .lineLimit(1)
                }

                HStack(alignment: .center, spacing: 8) {
                    Text(messagePreview)
                        .font(.subheadline)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .lineLimit(1)
                        .truncationMode(.tail)

                    Spacer()

                    if unreadCount > 0 {
                        Text("\(unreadCount)")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(Color("AppBlue")))
                            .foregroundStyle(.white)
                            .accessibilityLabel("\(unreadCount) unread messages")
                    }
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color("AppSurface"))
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color("AppSeparator"))
                .frame(height: 0.5)
        }
        .contentShape(Rectangle())
    }
}

#Preview {
    ChatListItem()
        .previewLayout(.sizeThatFits)
}
