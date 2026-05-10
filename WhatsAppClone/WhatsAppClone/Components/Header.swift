//
//  Header.swift
//  WhatsAppClone
//
//  Created by Xcode Assistant on 10/05/2026.
//

import SwiftUI

struct Header: View {
    enum HeaderStyle {
        case list
        case detail
    }

    let style: HeaderStyle
    let title: String
    let avatar: Image
    let onBlock: (() -> Void)?
    let onLogout: (() -> Void)?
    let blockTitle: String
    
    @Environment(\.dismiss) private var dismiss
    @State private var showListMenu: Bool = false
    @State private var showDetailMenu: Bool = false

    init(
        style: HeaderStyle,
        title: String,
        avatar: Image = Image("user"),
        onBlock: (() -> Void)? = nil,
        onLogout: (() -> Void)? = nil,
        blockTitle: String = "Block"
        
    ) {
        self.style = style
        self.title = title
        self.avatar = avatar
        self.onBlock = onBlock
        self.onLogout = onLogout
        self.blockTitle = blockTitle
    }

    var body: some View {
        switch style {
        case .list:
            listHeader
        case .detail:
            detailHeader
        }
    }

    private var listHeader: some View {
        HStack {
            Text("WhatsApp")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(Color.white)

            Spacer()

            Button {
                showListMenu = true
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.white)
                    .frame(width: 36, height: 36)
                    .contentShape(Rectangle())
                    .rotationEffect(.degrees(90))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Menu")
            .confirmationDialog(
                "Menu",
                isPresented: $showListMenu,
                titleVisibility: .visible
            ) {
                Button("Logout", role: .destructive) {
                    onLogout?()
                }

                Button("Cancel", role: .cancel) {}
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 14)
        .background(Color("AppBlue"))
    }

    private var detailHeader: some View {
        HStack(spacing: 12) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.white)
                    .frame(width: 32, height: 32)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Back")

            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .foregroundStyle(Color.white)

            Text(title)
                .font(.headline)
                .foregroundStyle(Color.white)
                .lineLimit(1)

            Spacer(minLength: 0)

            Button {
                showDetailMenu = true
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.white)
                    .frame(width: 36, height: 36)
                    .contentShape(Rectangle())
                    .rotationEffect(.degrees(90))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Menu")
            .confirmationDialog(
                "Menu",
                isPresented: $showDetailMenu,
                titleVisibility: .visible
            ) {
                Button(blockTitle, role: .destructive) {
                    onBlock?()
                }

                Button("Cancel", role: .cancel) {}
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color("AppBlue"))
    }
}

#Preview("List Header") {
    Header(
        style: .list,
        title: "WhatsApp",
        onLogout: {
            print("Logout tapped")
        }
    )
    .previewLayout(.sizeThatFits)
}

#Preview("Detail Header") {
    Header(
        style: .detail,
        title: "John Doe",
        onBlock: {
            print("Block tapped")
        }
    )
    .previewLayout(.sizeThatFits)
}
