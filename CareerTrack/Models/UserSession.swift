import Foundation

/// The signed-in user. In Demo Mode `isDemo` is true and nothing is sent to Firebase.
struct UserSession: Equatable {
    let uid: String
    let email: String
    let isDemo: Bool

    static let demo = UserSession(uid: "demo-user", email: "demo@careertrack.app", isDemo: true)
}
