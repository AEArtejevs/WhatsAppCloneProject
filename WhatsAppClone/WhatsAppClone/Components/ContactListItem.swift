//
//  ContactListItem.swift
//  WhatsAppClone
//
//  Created by Andris on 10/05/2026.
//

import SwiftUI

struct ContactListItem: View {
    let contact: ContactResponse

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

            VStack(alignment: .leading, spacing: 4) {
                Text(contact.username)
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(1)

                Text(contact.email)
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .lineLimit(1)
            }

            Spacer()
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
    ContactListItem(
        contact: ContactResponse(
            id: 2,
            username: "test2",
            email: "test2@test.com",
            createdAt: "2026-05-10"
        )
    )
    .previewLayout(.sizeThatFits)
}
