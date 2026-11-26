import SwiftUI

/// Applications tab: search, filter by status, sort by date, swipe to delete.
struct ApplicationListView: View {
    @EnvironmentObject private var auth: AuthViewModel
    @EnvironmentObject private var applications: ApplicationViewModel
    @EnvironmentObject private var interviews: InterviewViewModel

    @State private var searchText = ""
    @State private var statusFilter: ApplicationStatus?
    @State private var sortOrder: DateSortOrder = .newestFirst
    @State private var showingAddForm = false
    @State private var applicationToDelete: JobApplication?

    private var results: [JobApplication] {
        applications.filteredApplications(searchText: searchText, status: statusFilter, order: sortOrder)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                StatusFilterBar(selection: $statusFilter)
                    .padding(.vertical, 6)

                if auth.session?.isDemo == true {
                    DemoModeBanner().padding(.horizontal)
                }

                if results.isEmpty {
                    Spacer()
                    if applications.totalCount == 0 {
                        EmptyStateView(icon: "tray", title: "No applications yet",
                                       message: "Keep track of every job and internship you apply for.",
                                       buttonTitle: "Add Application") { showingAddForm = true }
                    } else {
                        EmptyStateView(icon: "magnifyingglass", title: "No matches",
                                       message: "Try a different search or status filter.")
                    }
                    Spacer()
                } else {
                    applicationList
                }
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Applications")
            .searchable(text: $searchText, prompt: "Search company or position")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Picker("Sort", selection: $sortOrder) {
                            ForEach(DateSortOrder.allCases) { order in
                                Text(order.rawValue).tag(order)
                            }
                        }
                    } label: {
                        Label("Sort", systemImage: "arrow.up.arrow.down")
                    }
                }
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
                ApplicationFormView(existing: nil)
            }
            .confirmationDialog("Delete this application?",
                                isPresented: Binding(get: { applicationToDelete != nil },
                                                     set: { if !$0 { applicationToDelete = nil } }),
                                titleVisibility: .visible) {
                Button("Delete", role: .destructive) {
                    if let app = applicationToDelete {
                        Task {
                            await interviews.deleteInterviews(forApplication: app.id)
                            await applications.delete(app)
                        }
                    }
                    applicationToDelete = nil
                }
                Button("Cancel", role: .cancel) { applicationToDelete = nil }
            } message: {
                Text("Linked interviews will also be deleted. This cannot be undone.")
            }
        }
    }

    private var applicationList: some View {
        List {
            Text("\(results.count) application(s) • \(sortOrder.rawValue)")
                .font(.caption)
                .foregroundColor(.secondary)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)

            ForEach(results) { app in
                NavigationLink(value: AppRoute.applicationDetail(id: app.id)) {
                    ApplicationCard(application: app)
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button {
                        applicationToDelete = app
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    .tint(.red)
                }
            }
        }
        .listStyle(.plain)
        .animation(.default, value: results)
    }
}
