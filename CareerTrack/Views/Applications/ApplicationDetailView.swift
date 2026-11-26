import SwiftUI

/// Shows one application. Looks the application up by id so edits appear immediately.
struct ApplicationDetailView: View {
    let applicationId: String

    @EnvironmentObject private var applications: ApplicationViewModel
    @EnvironmentObject private var interviews: InterviewViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    @State private var showingEdit = false
    @State private var showingDeleteDialog = false
    @State private var showingAddInterview = false
    @State private var interviewToEdit: Interview?

    var body: some View {
        Group {
            if let app = applications.application(withId: applicationId) {
                content(for: app)
            } else {
                EmptyStateView(icon: "questionmark.folder", title: "Application not found",
                               message: "It may have been deleted.")
            }
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func content(for app: JobApplication) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                headerCard(app)
                statusPicker(app)
                infoCard(app)
                notesCard(app)
                interviewsSection(app)
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button { showingEdit = true } label: { Label("Edit", systemImage: "pencil") }
                    Button(role: .destructive) { showingDeleteDialog = true } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingEdit) {
            ApplicationFormView(existing: app)
        }
        .sheet(isPresented: $showingAddInterview) {
            InterviewFormView(existing: nil, preselectedApplicationId: app.id)
        }
        .sheet(item: $interviewToEdit) { interview in
            InterviewFormView(existing: interview)
        }
        .confirmationDialog("Delete \(app.companyName) application?", isPresented: $showingDeleteDialog,
                            titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                dismiss()
                Task {
                    await interviews.deleteInterviews(forApplication: app.id)
                    await applications.delete(app)
                }
            }
        } message: {
            Text("Linked interviews will also be deleted.")
        }
    }

    // MARK: - Cards

    private func headerCard(_ app: JobApplication) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                StatusBadge(status: app.status, showsIcon: true)
                Spacer()
                Text(app.jobType.rawValue)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Theme.navy.opacity(0.1))
                    .foregroundColor(Theme.navy)
                    .clipShape(Capsule())
            }
            Text(app.position)
                .font(.title2.bold())
            Text(app.companyName)
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }

    /// Quick status change without opening the edit form.
    private func statusPicker(_ app: JobApplication) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Update status").font(.subheadline.bold())
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(ApplicationStatus.allCases) { status in
                        Button {
                            Task { await applications.updateStatus(of: app.id, to: status) }
                        } label: {
                            Text(status.rawValue)
                                .font(.caption.weight(.semibold))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .foregroundColor(app.status == status ? .white : status.color)
                                .background(app.status == status ? status.color : status.color.opacity(0.12))
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .cardStyle()
    }

    private func infoCard(_ app: JobApplication) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            DetailRow(icon: "calendar", title: "Application date", value: app.applicationDate.shortDate)
            DetailRow(icon: "mappin.and.ellipse", title: "Location", value: app.location)
            if let salary = app.salary {
                DetailRow(icon: "banknote", title: "Salary / compensation", value: salary)
            }
            if let followUp = app.followUpDate {
                DetailRow(icon: "bell", title: "Follow-up", value: "\(followUp.dateAndTime) (\(followUp.relativeDescription))")
            }
            if let url = app.validJobURL {
                Button {
                    openURL(url)
                } label: {
                    Label("Open job posting", systemImage: "link")
                        .font(.subheadline.weight(.semibold))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }

    private func notesCard(_ app: JobApplication) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Notes").font(.subheadline.bold())
            Text(app.notes.isEmpty ? "No notes added." : app.notes)
                .font(.body)
                .foregroundColor(app.notes.isEmpty ? .secondary : .primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }

    private func interviewsSection(_ app: JobApplication) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Interviews", actionTitle: "Schedule") {
                showingAddInterview = true
            }
            let linked = interviews.linkedInterviews(applicationId: app.id)
            if linked.isEmpty {
                Text("No interviews linked to this application yet.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .cardStyle()
            } else {
                ForEach(linked) { interview in
                    Button {
                        interviewToEdit = interview
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            InterviewCard(interview: interview)
                            if !interview.preparationNotes.isEmpty {
                                Text(interview.preparationNotes)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 6)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
