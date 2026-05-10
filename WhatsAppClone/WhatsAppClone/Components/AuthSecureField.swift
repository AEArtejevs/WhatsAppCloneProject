//
//  AuthSecureField.swift
//  WhatsAppClone
//
//  Created by Andris on 10/05/2026.
//

import SwiftUI

struct AuthSecureField: View {
    let title: String
    @Binding var text: String

    var body: some View {
        SecureField(title, text: $text)
            .textInputAutocapitalization(TextInputAutocapitalization.never)
            .autocorrectionDisabled(true)
            .padding()
            .background(Color(.appSearchBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    AuthSecureField(
        title: "Password",
        text: .constant("")
    )
    .padding()
}
