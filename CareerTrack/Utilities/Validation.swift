import Foundation

/// Small, reusable input checks used by the auth and form screens.
enum Validation {
    static func isBlank(_ text: String) -> Bool {
        text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    static func isValidEmail(_ email: String) -> Bool {
        let pattern = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        return NSPredicate(format: "SELF MATCHES %@", pattern)
            .evaluate(with: email.trimmingCharacters(in: .whitespaces))
    }

    static func isValidYear(_ text: String) -> Bool {
        guard let year = Int(text), text.count == 4 else { return false }
        return (1950...2100).contains(year)
    }

    static func isValidURL(_ text: String) -> Bool {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        let withScheme = trimmed.lowercased().hasPrefix("http") ? trimmed : "https://\(trimmed)"
        guard let url = URL(string: withScheme), let host = url.host else { return false }
        return host.contains(".")
    }

    /// Returns nil when valid, otherwise an error message.
    static func loginError(email: String, password: String) -> String? {
        if isBlank(email) || isBlank(password) { return "Please enter your email and password." }
        if !isValidEmail(email) { return "Please enter a valid email address." }
        return nil
    }

    static func registerError(email: String, password: String, confirmPassword: String) -> String? {
        if isBlank(email) || isBlank(password) || isBlank(confirmPassword) { return "Please fill in all fields." }
        if !isValidEmail(email) { return "Please enter a valid email address." }
        if password.count < 6 { return "Password must be at least 6 characters." }
        if password != confirmPassword { return "Passwords do not match." }
        return nil
    }
}
