import SwiftUI

@main
struct CareerTrackApp: App {
    // @StateObject: the app owns these objects for its whole lifetime.
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var applicationViewModel = ApplicationViewModel()
    @StateObject private var interviewViewModel = InterviewViewModel()
    @StateObject private var profileViewModel = ProfileViewModel()
    @StateObject private var preparationViewModel = PreparationViewModel()

    init() {
        // Safe: does nothing if GoogleService-Info.plist is missing.
        FirebaseService.configureIfPossible()
        NotificationService.shared.configure()
    }

    var body: some Scene {
        WindowGroup {
            AppRootView()
                // Environment injection: every child view can read these objects.
                .environmentObject(authViewModel)
                .environmentObject(applicationViewModel)
                .environmentObject(interviewViewModel)
                .environmentObject(profileViewModel)
                .environmentObject(preparationViewModel)
                .tint(Theme.navy)
        }
    }
}
