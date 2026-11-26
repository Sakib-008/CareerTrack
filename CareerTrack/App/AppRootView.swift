import SwiftUI

/// Decides which screen to show: loading, login, or the main tabs.
struct AppRootView: View {
    @EnvironmentObject private var auth: AuthViewModel

    var body: some View {
        Group {
            if auth.isCheckingSession {
                ProgressView("Loading…")
            } else if let session = auth.session {
                MainTabView(session: session)
                    .transition(.opacity)
            } else {
                LoginView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: auth.session)
        .onAppear { auth.start() }
    }
}
