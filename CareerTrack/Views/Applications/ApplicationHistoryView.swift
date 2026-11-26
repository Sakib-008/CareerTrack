import SwiftUI

/// Full application history grouped by month.
/// Search by company or position, filter by status, sort newest/oldest.
struct ApplicationHistoryView: View {
    @EnvironmentObject private var applications: ApplicationViewModel

    @State private var searchText = ""
    @State private var searchField: SearchField = .company
    @State private var statusFilter: ApplicationStatus?
    @State private var sortOrder: DateSortOrder = .newestFirst

    private var results: [JobApplication] {
        applications.filteredApplications(searchText: searchText, field: searchField,
                                          status: statusFilter, order: sortOrder)
    }

    /// Groups results by "Month Year", keeping the sort order.
    private var groupedResults: [MonthGroup] {
        var groups: [MonthGroup] = []
        for app in results {
            let month = app.applicationDate.monthAndYear
            if let index = groups.firstIndex(where: { $0.month == month }) {
                groups[index].items.append(app)
            } else {
                groups.append(MonthGroup(month: month, items: [app]))
            }
        }
        return groups
    }

    private var searchPrompt: String {
        searchField == .position ? "Search position" : (searchField == .company ? "Search company" : "Search company or position")
    }

    var body: some View {
        List {
            Section {
                Picker("Search in", selection: $searchField) {
                    ForEach(SearchField.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)

                Picker("Status", selection: $statusFilter) {
                    Text("All statuses").tag(ApplicationStatus?.none)
                    ForEach(ApplicationStatus.allCases) { status in
                        Text(status.rawValue).tag(ApplicationStatus?.some(status))
                    }
                }

                Picker("Sort by date", selection: $sortOrder) {
                    ForEach(DateSortOrder.allCases) { Text($0.rawValue).tag($0) }
                }
            }

            if results.isEmpty {
                EmptyStateView(icon: "clock.arrow.circlepath", title: "No applications found",
                               message: "Change the search text or filters.")
                    .listRowBackground(Color.clear)
            } else {
                ForEach(groupedResults) { group in
                    Section("\(group.month) (\(group.items.count))") {
                        ForEach(group.items) { app in
                            NavigationLink(value: AppRoute.applicationDetail(id: app.id)) {
                                historyRow(app)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("History")
        .searchable(text: $searchText, prompt: searchPrompt)
    }

    private func historyRow(_ app: JobApplication) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(app.companyName).font(.headline)
                Text(app.position).font(.subheadline).foregroundColor(.secondary)
                Text(app.applicationDate.shortDate).font(.caption).foregroundColor(.secondary)
            }
            Spacer()
            StatusBadge(status: app.status)
        }
        .padding(.vertical, 4)
    }
}

/// Applications that share the same month (used by the history list).
struct MonthGroup: Identifiable {
    let month: String
    var items: [JobApplication]

    var id: String { month }
}
