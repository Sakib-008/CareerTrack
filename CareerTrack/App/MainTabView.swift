import SwiftUI

enum MainTab: Hashable {
    case dashboard, applications, interviews, preparation, profile
}

/// The authenticated part of the app.
struct MainTabView: View {
    let session: UserSession

    @EnvironmentObject private var applications: ApplicationViewModel
    @EnvironmentObject private var interviews: InterviewViewModel
    @EnvironmentObject private var profile: ProfileViewModel

    @State private var selectedTab: MainTab = .dashboard

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView(selectedTab: $selectedTab)
                .tabItem { Label("Dashboard", systemImage: "square.grid.2x2.fill") }
                .tag(MainTab.dashboard)

            ApplicationListView()
                .tabItem { Label("Applications", systemImage: "tray.full.fill") }
                .tag(MainTab.applications)

            InterviewListView()
                .tabItem { Label("Interviews", systemImage: "calendar") }
                .tag(MainTab.interviews)

            InterviewPreparationView()
                .tabItem { Label("Prepare", systemImage: "book.fill") }
                .tag(MainTab.preparation)

            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.crop.circle") }
                .tag(MainTab.profile)
        }
        // Reloads all data whenever a different user signs in.
        .task(id: session.uid) {
            await applications.load(for: session)
            await interviews.load(for: session)
            await profile.load(for: session)
        }
    }
}
