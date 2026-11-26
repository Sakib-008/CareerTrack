import SwiftUI

struct RegisterView: View {
    @EnvironmentObject private var auth: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 6) {
                    Text("Create Account")
                        .font(.largeTitle.bold())
                        .foregroundColor(Theme.navy)
                    Text("Start tracking your career journey.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)

                VStack(spacing: 14) {
                    AuthTextField(icon: "envelope", placeholder: "Email", text: $email, keyboard: .emailAddress)
                    AuthTextField(icon: "lock", placeholder: "Password (min. 6 characters)",
                                  text: $password, isSecure: true)
                    AuthTextField(icon: "lock.rotation", placeholder: "Confirm password",
                                  text: $confirmPassword, isSecure: true)
                }

                if let error = auth.errorMessage {
                    ErrorText(message: error)
                }

                PrimaryButton(title: "Register", icon: "person.badge.plus", isLoading: auth.isLoading) {
                    Task {
                        await auth.register(email: email, password: password, confirmPassword: confirmPassword)
                    }
                }
                .disabled(!auth.isFirebaseAvailable)

                Button("Already have an account? Log in") { dismiss() }
                    .font(.subheadline)
                    .foregroundColor(Theme.navy)
            }
            .padding(24)
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle("Register")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { auth.clearError() }
        .onDisappear { auth.clearError() }
    }
}
