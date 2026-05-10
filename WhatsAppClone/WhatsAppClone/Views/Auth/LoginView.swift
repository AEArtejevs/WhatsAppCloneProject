//
//  LoginView.swift
//  WhatsAppClone
//
//  Created by Andris on 27/04/2026.
//

import SwiftUI

// Login screen for existing users.
// The view only displays the form and calls AuthViewModel to handle login logic.
struct LoginView: View {
    // Shared authentication ViewModel from the app.
    // It stores the current user, token, loading state, and error messages.
    @EnvironmentObject private var authViewModel: AuthViewModel

    // Local input values typed by the user.
    @State private var email: String = ""
    @State private var password: String = ""

    var body: some View {
        // NavigationStack allows this screen to open RegisterView.
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()

                // App title shown at the top of the login screen.
                Text("WhatsAppClone")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(Color("AppTextPrimary"))

                Text("Login to continue")
                    .font(.subheadline)
                    .foregroundStyle(Color("AppTextSecondary"))

                // Reusable input components for email and password fields.
                VStack(spacing: 12) {
                    AuthTextField(
                        title: "Email",
                        text: $email,
                        keyboardType: .emailAddress
                    )

                    AuthSecureField(
                        title: "Password",
                        text: $password
                    )
                }

                // Login button calls AuthViewModel, which sends the login request to the backend.
                Button {
                    authViewModel.login(
                        email: email,
                        password: password
                    )
                } label: {
                    Text(authViewModel.isLoading ? "Logging in..." : "Login")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(authViewModel.isLoading ? Color("AppTextSecondary") : Color("AppBlue"))
                        .foregroundStyle(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                // Prevents sending multiple login requests at the same time.
                .disabled(authViewModel.isLoading)

                // Shows validation or backend error messages.
                if let errorMessage = authViewModel.errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(Color("AppDanger"))
                        .multilineTextAlignment(.center)
                }

                // Opens the registration screen for new users.
                NavigationLink {
                    RegisterView()
                } label: {
                    Text("Create new account")
                        .fontWeight(.medium)
                        .foregroundStyle(Color("AppBlue"))
                }
                // Prevents sending multiple login requests at the same time.
                .disabled(authViewModel.isLoading)

                Spacer()
            }
            // Uses the named background color so light and dark mode stay consistent.
            .padding()
            .background(Color("AppBackground"))
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}
