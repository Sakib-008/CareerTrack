import Foundation
import FirebaseAuth

/// Thin wrapper around Firebase Authentication (email/password).
/// Only call these methods when FirebaseService.isConfigured is true.
final class AuthService {
    static let shared = AuthService()
    private init() {}

    private var listenerHandle: AuthStateDidChangeListenerHandle?

    func register(email: String, password: String) async throws -> UserSession {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        return session(from: result.user)
    }

    func login(email: String, password: String) async throws -> UserSession {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        return session(from: result.user)
    }

    func logout() throws {
        try Auth.auth().signOut()
    }

    /// Calls `handler` now and every time the signed-in user changes.
    func observeAuthState(_ handler: @escaping (UserSession?) -> Void) {
        stopObserving()
        listenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }
            handler(user.map { self.session(from: $0) })
        }
    }

    func stopObserving() {
        if let handle = listenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
            listenerHandle = nil
        }
    }

    private func session(from user: User) -> UserSession {
        UserSession(uid: user.uid, email: user.email ?? "", isDemo: false)
    }

    /// Converts Firebase error codes into friendly messages.
    static func friendlyMessage(for error: Error) -> String {
        let nsError = error as NSError
        switch nsError.code {
        case 17007: return "An account with this email already exists."
        case 17008: return "The email address is badly formatted."
        case 17009, 17004: return "Incorrect email or password."
        case 17011: return "No account found with this email."
        case 17010: return "Too many attempts. Please try again later."
        case 17020: return "Network error. Check your internet connection."
        case 17026: return "Password is too weak. Use at least 6 characters."
        default: return nsError.localizedDescription
        }
    }
}
