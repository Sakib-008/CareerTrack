import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var auth: AuthViewModel

    @State private var email = ""
    @State private var password = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    header

                    if !auth.isFirebaseAvailable {
                        firebaseMissingNotice
                    }

                    VStack(spacing: 14) {
                        AuthTextField(icon: "envelope", placeholder: "Email", text: $email,
                                      keyboard: .emailAddress)
                        AuthTextField(icon: "lock", placeholder: "Password", text: $password, isSecure: true)
                    }

                    if let error = auth.errorMessage {
                        ErrorText(message: error)
                    }

                    PrimaryButton(title: "Log In", icon: "arrow.right.circle.fill", isLoading: auth.isLoading) {
                        Task { await auth.login(email: email, password: password) }
                    }
                    .disabled(!auth.isFirebaseAvailable)

                    NavigationLink {
                        RegisterView()
                    } label: {
                        Text("Don't have an account? **Register**")
                            .font(.subheadline)
                            .foregroundColor(Theme.navy)
                    }

                    dividerWithText("or")

                    Button {
                        auth.enterDemoMode()
                    } label: {
                        Label("Explore Demo Mode", systemImage: "sparkles")
                            .font(.body.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .foregroundColor(Theme.navy)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.navy, lineWidth: 1.5))
                    }

                    Text("Demo Mode uses local sample data and does not need Firebase.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(24)
            }
            .background(Theme.background.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
            .onDisappear { auth.clearError() }
        }
    }

    private var header: some View {
        VStack(spacing: 10) {
            Image(systemName: "briefcase.fill")
                .font(.system(size: 40))
                .foregroundColor(.white)
                .frame(width: 84, height: 84)
                .background(Theme.navy)
                .clipShape(RoundedRectangle(cornerRadius: 22))
            Text("CareerTrack")
                .font(.largeTitle.bold())
                .foregroundColor(Theme.navy)
            Text("Track every job & internship application in one place.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 30)
    }

    private var firebaseMissingNotice: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("Firebase is not configured", systemImage: "exclamationmark.triangle.fill")
                .font(.subheadline.bold())
            Text("GoogleService-Info.plist was not found in the app. Login and registration are disabled. Follow SETUP_GUIDE.md, or use Demo Mode below.")
                .font(.caption)
        }
        .foregroundColor(.orange)
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.orange.opacity(0.12))
        .cornerRadius(12)
    }

    private func dividerWithText(_ text: String) -> some View {
        HStack {
            Rectangle().fill(Color.secondary.opacity(0.3)).frame(height: 1)
            Text(text).font(.caption).foregroundColor(.secondary)
            Rectangle().fill(Color.secondary.opacity(0.3)).frame(height: 1)
        }
    }
}

/// Rounded text field used on the login and register screens.
struct AuthTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var keyboard: UIKeyboardType = .default
    var isSecure = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .frame(width: 20)
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(keyboard)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
            }
        }
        .padding()
        .background(Theme.card)
        .cornerRadius(12)
    }
}

/// Red inline error message.
struct ErrorText: View {
    let message: String

    var body: some View {
        Label(message, systemImage: "exclamationmark.circle.fill")
            .font(.footnote)
            .foregroundColor(.red)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView().environmentObject(AuthViewModel())
    }
}
