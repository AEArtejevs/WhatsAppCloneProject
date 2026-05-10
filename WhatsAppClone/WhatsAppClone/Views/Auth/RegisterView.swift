//
//  RegisterView.swift
//  WhatsAppClone
//
//  Created by Andris on 27/04/2026.
//

import SwiftUI

// Registration screen where a new user creates an account.
// This view displays the form and calls AuthViewModel to send registration data to the backend.
struct RegisterView: View {
    // Shared authentication ViewModel from the app.
    // It handles register/login requests, loading state, errors, token, and current user.
    @EnvironmentObject private var authViewModel: AuthViewModel

    // Local form values entered by the user.
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Create Account")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(Color("AppTextPrimary"))

            // Reusable input components used for the registration form.
            VStack(spacing: 12) {
                AuthTextField(
                    title: "Username",
                    text: $username
                )

                AuthTextField(
                    title: "Email",
                    text: $email,
                    keyboardType: .emailAddress
                )

                AuthSecureField(
                    title: "Password",
                    text: $password
                )

                AuthSecureField(
                    title: "Confirm Password",
                    text: $confirmPassword
                )
            }

            // Calls AuthViewModel.register(), which sends POST /auth/register to the backend.
            Button {
                authViewModel.register(
                    username: username,
                    email: email,
                    password: password,
                    confirmPassword: confirmPassword
                )
            } label: {
                Text(authViewModel.isLoading ? "Creating..." : "Register")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(authViewModel.isLoading ? Color("AppTextSecondary") : Color("AppBlue"))
                    .foregroundStyle(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            // Prevents duplicate account creation requests while loading.
            .disabled(authViewModel.isLoading)

            // Shows validation or backend errors, for example duplicate email or password mismatch.
            if let errorMessage = authViewModel.errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(Color("AppDanger"))
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
        .padding()
        .background(Color("AppBackground"))
        .navigationTitle("Register")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Clears old login/register errors when this screen opens.
            authViewModel.errorMessage = nil
        }
    }
}

#Preview {
    NavigationStack {
        RegisterView()
            .environmentObject(AuthViewModel())
    }
}
