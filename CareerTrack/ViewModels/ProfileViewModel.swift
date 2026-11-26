import Foundation

/// Owns the user's career profile.
final class ProfileViewModel: ObservableObject {
    @Published private(set) var profile: CareerProfile = .empty
    @Published private(set) var isLoading = false
    @Published private(set) var isSaving = false
    @Published var errorMessage: String?

    private var session: UserSession?

    @MainActor
    func load(for session: UserSession) async {
        self.session = session
        profile = .empty

        if session.isDemo {
            profile = LocalDataService.sampleProfile(email: session.email)
            return
        }

        isLoading = true
        do {
            if let stored = try await FirestoreService.shared.fetchProfile(uid: session.uid) {
                profile = stored
            } else {
                // First login: start with the account email filled in.
                var fresh = CareerProfile.empty
                fresh.email = session.email
                profile = fresh
            }
        } catch {
            errorMessage = "Could not load profile: \(error.localizedDescription)"
        }
        isLoading = false
    }

    /// Returns true when the profile was saved successfully.
    @MainActor
    func save(_ newProfile: CareerProfile) async -> Bool {
        guard let session = session else { return false }
        profile = newProfile
        if session.isDemo { return true }

        isSaving = true
        defer { isSaving = false }
        do {
            try await FirestoreService.shared.saveProfile(newProfile, uid: session.uid)
            return true
        } catch {
            errorMessage = "Could not save profile: \(error.localizedDescription)"
            return false
        }
    }
}
