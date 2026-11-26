import Foundation

/// Owns the authentication state for the whole app.
final class AuthViewModel: ObservableObject {
    @Published private(set) var session: UserSession?
    @Published private(set) var isCheckingSession = true
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var hasStarted = false

    /// False when GoogleService-Info.plist is missing.
    var isFirebaseAvailable: Bool { FirebaseService.isConfigured }

    /// Starts listening for Firebase auth changes (called once from AppRootView).
    func start() {
        guard !hasStarted else { return }
        hasStarted = true

        guard isFirebaseAvailable else {
            isCheckingSession = false
            return
        }

        AuthService.shared.observeAuthState { [weak self] newSession in
            DispatchQueue.main.async {
                guard let self = self else { return }
                // Firebase reporting "no user" must not end an active Demo Mode session.
                if newSession == nil && self.session?.isDemo == true {
                    self.isCheckingSession = false
                    return
                }
                self.session = newSession
                self.isCheckingSession = false
            }
        }
    }

    @MainActor
    func login(email: String, password: String) async {
        if let message = Validation.loginError(email: email, password: password) {
            errorMessage = message
            return
        }
        guard isFirebaseAvailable else {
            errorMessage = "Firebase is not configured. Add GoogleService-Info.plist or use Demo Mode."
            return
        }

        isLoading = true
        errorMessage = nil
        do {
            session = try await AuthService.shared.login(email: email.trimmingCharacters(in: .whitespaces),
                                                          password: password)
        } catch {
            errorMessage = AuthService.friendlyMessage(for: error)
        }
        isLoading = false
    }

    @MainActor
    func register(email: String, password: String, confirmPassword: String) async {
        if let message = Validation.registerError(email: email, password: password, confirmPassword: confirmPassword) {
            errorMessage = message
            return
        }
        guard isFirebaseAvailable else {
            errorMessage = "Firebase is not configured. Add GoogleService-Info.plist or use Demo Mode."
            return
        }

        isLoading = true
        errorMessage = nil
        do {
            session = try await AuthService.shared.register(email: email.trimmingCharacters(in: .whitespaces),
                                                             password: password)
        } catch {
            errorMessage = AuthService.friendlyMessage(for: error)
        }
        isLoading = false
    }

    func enterDemoMode() {
        errorMessage = nil
        session = .demo
    }

    func logout() {
        if session?.isDemo == false {
            do {
                try AuthService.shared.logout()
            } catch {
                errorMessage = AuthService.friendlyMessage(for: error)
                return
            }
        }
        NotificationService.shared.cancelAll()
        session = nil
    }

    func clearError() {
        errorMessage = nil
    }
}
