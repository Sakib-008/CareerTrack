import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var auth: AuthViewModel
    @EnvironmentObject private var profileVM: ProfileViewModel

    @State private var showingEdit = false
    @State private var showingLogoutDialog = false

    private var profile: CareerProfile { profileVM.profile }

    private var logoutTitle: String {
        auth.session?.isDemo == true ? "Exit Demo Mode" : "Log Out"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if auth.session?.isDemo == true {
                        DemoModeBanner()
                    }
                    if let error = profileVM.errorMessage {
                        ErrorText(message: error)
                    }

                    header

                    if profile.fullName.isEmpty {
                        EmptyStateView(icon: "person.text.rectangle", title: "Complete your profile",
                                       message: "Add your education, skills and experience.",
                                       buttonTitle: "Edit Profile") { showingEdit = true }
                            .cardStyle()
                    }

                    Group {
                        contactCard
                        educationCard
                        skillsCard
                        textCard(title: "Career Summary", icon: "text.alignleft", text: profile.summary)
                        textCard(title: "Work Experience", icon: "briefcase", text: profile.workExperience)
                        linksCard
                    }

                    Button {
                        showingLogoutDialog = true
                    } label: {
                        Label(
                            logoutTitle,
                            systemImage: "rectangle.portrait.and.arrow.right"
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                }
                .padding()
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Profile")
            .overlay {
                if profileVM.isLoading { ProgressView() }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") { showingEdit = true }
                }
            }
            .withAppRoutes()
            .sheet(isPresented: $showingEdit) {
                ProfileEditView(profile: profile)
            }
            .confirmationDialog(
                "Are you sure you want to log out?",
                isPresented: $showingLogoutDialog,
                titleVisibility: .visible
            ) {
                Button("Log Out") {
                    auth.logout()
                }

                Button("Cancel") {
                    showingLogoutDialog = false
                }
            }
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            Text(profile.initials)
                .font(.title.bold())
                .foregroundColor(.white)
                .frame(width: 84, height: 84)
                .background(Theme.navy)
                .clipShape(Circle())
            Text(profile.fullName.isEmpty ? "Your Name" : profile.fullName)
                .font(.title2.bold())
            Text(auth.session?.email ?? "")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }

    private var contactCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            cardTitle("Contact", icon: "person.crop.circle")
            DetailRow(icon: "envelope", title: "Email", value: valueOrDash(profile.email))
            DetailRow(icon: "phone", title: "Phone", value: valueOrDash(profile.phone))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }

    private var educationCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            cardTitle("Education", icon: "graduationcap")
            DetailRow(icon: "building.columns", title: "University", value: valueOrDash(profile.university))
            DetailRow(icon: "book.closed", title: "Degree / Program", value: valueOrDash(profile.degree))
            DetailRow(icon: "calendar", title: "Graduation Year", value: valueOrDash(profile.graduationYear))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }

    private var skillsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            cardTitle("Skills", icon: "star")
            if profile.skills.isEmpty {
                Text("No skills added yet.").font(.subheadline).foregroundColor(.secondary)
            } else {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 90), spacing: 8)], alignment: .leading, spacing: 8) {
                    ForEach(profile.skills, id: \.self) { skill in
                        Text(skill)
                            .font(.caption.weight(.semibold))
                            .lineLimit(1)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .frame(maxWidth: .infinity)
                            .background(Theme.navy.opacity(0.1))
                            .foregroundColor(Theme.navy)
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }

    private func textCard(title: String, icon: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            cardTitle(title, icon: icon)
            Text(text.isEmpty ? "Not added yet." : text)
                .font(.subheadline)
                .foregroundColor(text.isEmpty ? .secondary : .primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }

    private var linksCard: some View {
        VStack(spacing: 0) {
            NavigationLink(value: AppRoute.history) {
                linkRow(title: "Application History", icon: "clock.arrow.circlepath")
            }
            Divider()
            NavigationLink(value: AppRoute.analytics) {
                linkRow(title: "Analytics", icon: "chart.bar.fill")
            }
        }
        .buttonStyle(.plain)
        .cardStyle()
    }

    private func linkRow(title: String, icon: String) -> some View {
        HStack {
            Image(systemName: icon).foregroundColor(Theme.navy).frame(width: 24)
            Text(title)
            Spacer()
            Image(systemName: "chevron.right").font(.caption).foregroundColor(.secondary)
        }
        .padding(.vertical, 10)
        .contentShape(Rectangle())
    }

    private func cardTitle(_ title: String, icon: String) -> some View {
        Label(title, systemImage: icon)
            .font(.headline)
            .foregroundColor(Theme.navy)
    }

    private func valueOrDash(_ value: String) -> String {
        value.isEmpty ? "—" : value
    }
}
