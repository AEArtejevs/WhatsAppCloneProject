//
//  TextField.swift
//  WhatsAppClone
//
//  Created by Andris on 10/05/2026.
//

import SwiftUI
import UIKit

struct AuthTextField: View {
    let title: String
    @Binding var text: String

    var keyboardType: UIKeyboardType = .default

    var body: some View {
        TextField(title, text: $text)
            .keyboardType(keyboardType)
            .textInputAutocapitalization(TextInputAutocapitalization.never)
            .autocorrectionDisabled(true)
            .padding()
            .background(Color(.appSearchBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    VStack(spacing: 12) {
        AuthTextField(
            title: "Email",
            text: .constant(""),
            keyboardType: .emailAddress
        )

        AuthTextField(
            title: "Username",
            text: .constant("")
        )
    }
    .padding()
}
