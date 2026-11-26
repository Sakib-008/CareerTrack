import SwiftUI

/// Interviews tab with three segments: upcoming interviews, past interviews and follow-up reminders.
struct InterviewListView: View {
    enum Segment: String, CaseIterable, Identifiable {
        case upcoming = "Upcoming"
        case past = "Past"
        case followUps = "Follow-ups"
        var id: String { rawValue }
    }

    @EnvironmentObject private var interviews: InterviewViewModel
    @EnvironmentObject private var applications: ApplicationViewModel

    @State private var segment: Segment = .upcoming
    @State private var showingAddForm = false
    @State private var interviewToEdit: Interview?
    @State private var interviewToDelete: Interview?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Show", selection: $segment) {
                    ForEach(Segment.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)
                .padding()

                switch segment {
                case .upcoming:
                    interviewList(interviews.upcomingInterviews,
                                  emptyTitle: "No upcoming interviews",
                                  emptyMessage: "Schedule an interview to see it here.")
                case .past:
                    interviewList(interviews.pastInterviews,
                                  emptyTitle: "No past interviews",
                                  emptyMessage: "Completed interviews will appear here.")
                case .followUps:
                    followUpList
                }
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Interviews")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddForm = true
                    } label: {
                        Image(systemName: "plus.circle.fill").font(.title3)
                    }
                }
            }
            .withAppRoutes()
            .sheet(isPresented: $showingAddForm) {
                InterviewFormView(existing: nil)
            }
            .sheet(item: $interviewToEdit) { interview in
                InterviewFormView(existing: interview)
            }
            .alert("Delete interview?",
                   isPresented: Binding(get: { interviewToDelete != nil },
                                        set: { if !$0 { interviewToDelete = nil } })) {
                Button("Delete", role: .destructive) {
                    if let interview = interviewToDelete {
                        Task { await interviews.delete(interview) }
                    }
                    interviewToDelete = nil
                }
                Button("Cancel", role: .cancel) { interviewToDelete = nil }
            } message: {
                Text("This will also cancel its reminder.")
            }
        }
    }

    @ViewBuilder
    private func interviewList(_ items: [Interview], emptyTitle: String, emptyMessage: String) -> some View {
        if items.isEmpty {
            Spacer()
            EmptyStateView(icon: "calendar.badge.plus", title: emptyTitle, message: emptyMessage,
                           buttonTitle: "Schedule Interview") { showingAddForm = true }
            Spacer()
        } else {
            List {
                ForEach(items) { interview in
                    Button {
                        interviewToEdit = interview
                    } label: {
                        InterviewCard(interview: interview)
                    }
                    .buttonStyle(.plain)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button {
                            interviewToDelete = interview
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        .tint(.red)
                    }
                }
            }
            .listStyle(.plain)
        }
    }

    @ViewBuilder
    private var followUpList: some View {
        let followUps = applications.upcomingFollowUps
        if followUps.isEmpty {
            Spacer()
            EmptyStateView(icon: "bell.slash", title: "No follow-ups",
                           message: "Set a follow-up date when adding or editing an application.")
            Spacer()
        } else {
            List(followUps) { app in
                NavigationLink(value: AppRoute.applicationDetail(id: app.id)) {
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(app.companyName).font(.headline)
                            Text(app.position).font(.subheadline).foregroundColor(.secondary)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 3) {
                            Text(app.followUpDate?.shortDate ?? "")
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.orange)
                            Text(app.followUpDate?.relativeDescription ?? "")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .listStyle(.insetGrouped)
        }
    }
}
