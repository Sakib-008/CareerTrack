import SwiftUI

/// Home screen. Uses a NavigationPath so the app can navigate programmatically:
/// after "Quick Add" saves an application, the new application's detail screen is pushed automatically.
struct DashboardView: View {
    @Binding var selectedTab: MainTab

    @EnvironmentObject private var auth: AuthViewModel
    @EnvironmentObject private var applications: ApplicationViewModel
    @EnvironmentObject private var interviews: InterviewViewModel
    @EnvironmentObject private var profile: ProfileViewModel

    @State private var path = NavigationPath()
    @State private var showingAddForm = false
    @State private var newlyCreatedId: String?

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    welcomeHeader

                    if auth.session?.isDemo == true {
                        DemoModeBanner()
                    }

                    if let error = applications.errorMessage ?? interviews.errorMessage {
                        ErrorText(message: error)
                    }

                    statsGrid

                    PrimaryButton(title: "Add New Application", icon: "plus.circle.fill") {
                        showingAddForm = true
                    }

                    quickLinks

                    upcomingInterviewsSection

                    followUpsSection

                    recentActivitySection
                }
                .padding()
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Dashboard")
            .overlay {
                if applications.isLoading {
                    ProgressView()
                }
            }
            .withAppRoutes()
            .sheet(isPresented: $showingAddForm, onDismiss: openNewlyCreatedApplication) {
                ApplicationFormView(existing: nil) { saved in
                    newlyCreatedId = saved.id
                }
            }
        }
    }

    // MARK: - Sections

    private var welcomeHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(greeting)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(displayName)
                .font(.title.bold())
                .foregroundColor(Theme.navy)
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    private var statsGrid: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            StatCard(title: "Total applications", value: "\(applications.totalCount)",
                     icon: "tray.full.fill", color: Theme.navy)
            StatCard(title: "Applied", value: "\(applications.count(for: .applied))",
                     icon: ApplicationStatus.applied.iconName, color: ApplicationStatus.applied.color)
            StatCard(title: "Interviews", value: "\(applications.count(for: .interview))",
                     icon: ApplicationStatus.interview.iconName, color: ApplicationStatus.interview.color)
            StatCard(title: "Accepted offers", value: "\(applications.count(for: .accepted))",
                     icon: ApplicationStatus.accepted.iconName, color: ApplicationStatus.accepted.color)
        }
    }

    private var quickLinks: some View {
        HStack(spacing: 12) {
            NavigationLink(value: AppRoute.analytics) {
                quickLinkLabel(title: "Analytics", icon: "chart.bar.fill")
            }
            NavigationLink(value: AppRoute.history) {
                quickLinkLabel(title: "History", icon: "clock.arrow.circlepath")
            }
        }
        .buttonStyle(.plain)
    }

    private func quickLinkLabel(title: String, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
            Text(title).fontWeight(.semibold)
            Spacer()
            Image(systemName: "chevron.right").font(.caption)
        }
        .foregroundColor(Theme.navy)
        .cardStyle()
    }

    private var upcomingInterviewsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Upcoming Interviews", actionTitle: "See all") {
                selectedTab = .interviews
            }
            let upcoming = Array(interviews.upcomingInterviews.prefix(3))
            if upcoming.isEmpty {
                Text("No upcoming interviews.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .cardStyle()
            } else {
                ForEach(upcoming) { interview in
                    Button {
                        // Programmatic navigation with NavigationPath.
                        if let appId = interview.applicationId, applications.application(withId: appId) != nil {
                            path.append(AppRoute.applicationDetail(id: appId))
                        } else {
                            selectedTab = .interviews
                        }
                    } label: {
                        InterviewCard(interview: interview)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    @ViewBuilder
    private var followUpsSection: some View {
        let followUps = Array(applications.upcomingFollowUps.prefix(3))
        if !followUps.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                SectionHeader(title: "Follow-ups")
                ForEach(followUps) { app in
                    NavigationLink(value: AppRoute.applicationDetail(id: app.id)) {
                        HStack {
                            Image(systemName: "bell.fill")
                                .foregroundColor(.orange)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(app.companyName).font(.subheadline.bold())
                                Text(app.position).font(.caption).foregroundColor(.secondary)
                            }
                            Spacer()
                            Text(app.followUpDate?.shortDate ?? "")
                                .font(.caption.weight(.semibold))
                                .foregroundColor(.orange)
                        }
                        .cardStyle()
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Recent Activity", actionTitle: "See all") {
                selectedTab = .applications
            }
            let recent = applications.recentApplications()
            if recent.isEmpty {
                EmptyStateView(icon: "tray", title: "No applications yet",
                               message: "Tap \"Add New Application\" to record your first one.")
            } else {
                ForEach(recent) { app in
                    NavigationLink(value: AppRoute.applicationDetail(id: app.id)) {
                        ApplicationCard(application: app)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Helpers

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning 👋"
        case 12..<17: return "Good afternoon 👋"
        default: return "Good evening 👋"
        }
    }

    private var subtitle: String {
        if applications.totalCount == 0 { return "Add your first application to get started." }
        return "You have \(interviews.upcomingInterviews.count) upcoming interview(s)."
    }

    private var displayName: String {
        let name = profile.profile.fullName.trimmingCharacters(in: .whitespaces)
        if !name.isEmpty { return name.components(separatedBy: " ").first ?? name }
        let email = auth.session?.email ?? ""
        return email.components(separatedBy: "@").first ?? "Student"
    }

    private func openNewlyCreatedApplication() {
        guard let id = newlyCreatedId else { return }
        newlyCreatedId = nil
        path.append(AppRoute.applicationDetail(id: id))
    }
}
