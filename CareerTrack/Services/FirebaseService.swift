import Foundation
import FirebaseCore

/// Configures Firebase only when GoogleService-Info.plist is present in the app bundle.
/// If the file is missing the app does NOT crash; it offers Demo Mode instead.
enum FirebaseService {
    private(set) static var isConfigured = false

    static func configureIfPossible() {
        guard !isConfigured else { return }
        guard let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
              let options = FirebaseOptions(contentsOfFile: path) else {
            print("CareerTrack: GoogleService-Info.plist not found. Firebase disabled; Demo Mode available.")
            return
        }
        FirebaseApp.configure(options: options)
        isConfigured = true
    }
}
