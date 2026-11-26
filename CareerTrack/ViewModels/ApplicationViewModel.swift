import Foundation

/// Which text field the search box looks at.
enum SearchField: String, CaseIterable, Identifiable {
    case all = "All"
    case company = "Company"
    case position = "Position"

    var id: String { rawValue }
}

enum DateSortOrder: String, CaseIterable, Identifiable {
    case newestFirst = "Newest first"
    case oldestFirst = "Oldest first"

    var id: String { rawValue }
}

/// Owns the list of applications plus all application CRUD, statistics and filtering.
final class ApplicationViewModel: ObservableObject {
    @Published private(set) var applications: [JobApplication] = []
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    private var session: UserSession?

    // MARK: - Loading

    @MainActor
    func load(for session: UserSession) async {
        self.session = session
        applications = []

        if session.isDemo {
            applications = LocalDataService.sampleApplications()
            return
        }

        isLoading = true
        do {
            applications = try await FirestoreService.shared.fetchAll(JobApplication.self,
                                                                      from: .applications, uid: session.uid)
        } catch {
            errorMessage = "Could not load applications: \(error.localizedDescription)"
        }
        isLoading = false
    }

    // MARK: - CRUD

    /// Creates or updates an application (local list first, then Firestore).
    @MainActor
    func save(_ application: JobApplication) async {
        var item = application
        item.updatedAt = Date()

        if let index = applications.firstIndex(where: { $0.id == item.id }) {
            applications[index] = item
        } else {
            applications.append(item)
        }
        scheduleFollowUp(for: item)

        await persist { uid in
            try await FirestoreService.shared.save(item, id: item.id, in: .applications, uid: uid)
        }
    }

    @MainActor
    func updateStatus(of applicationId: String, to status: ApplicationStatus) async {
        guard var item = application(withId: applicationId), item.status != status else { return }
        item.status = status
        await save(item)
    }

    @MainActor
    func delete(_ application: JobApplication) async {
        applications.removeAll { $0.id == application.id }
        NotificationService.shared.cancel(id: followUpNotificationId(application.id))

        await persist { uid in
            try await FirestoreService.shared.delete(id: application.id, from: .applications, uid: uid)
        }
    }

    func application(withId id: String) -> JobApplication? {
        applications.first { $0.id == id }
    }

    // MARK: - Statistics (calculated from real data)

    var totalCount: Int { applications.count }

    func count(for status: ApplicationStatus) -> Int {
        applications.filter { $0.status == status }.count
    }

    func count(for jobType: JobType) -> Int {
        applications.filter { $0.jobType == jobType }.count
    }

    /// Most recently created or edited applications.
    func recentApplications(limit: Int = 4) -> [JobApplication] {
        Array(applications.sorted { $0.updatedAt > $1.updatedAt }.prefix(limit))
    }

    /// Applications with a follow-up date from today onwards, soonest first.
    var upcomingFollowUps: [JobApplication] {
        applications
            .filter { $0.hasUpcomingFollowUp }
            .sorted { ($0.followUpDate ?? .distantFuture) < ($1.followUpDate ?? .distantFuture) }
    }

    // MARK: - Search, filter and sort

    func filteredApplications(searchText: String,
                              field: SearchField = .all,
                              status: ApplicationStatus?,
                              order: DateSortOrder) -> [JobApplication] {
        let query = searchText.trimmingCharacters(in: .whitespaces).lowercased()

        let filtered = applications.filter { app in
            let matchesStatus = status == nil || app.status == status
            guard !query.isEmpty else { return matchesStatus }

            let company = app.companyName.lowercased().contains(query)
            let position = app.position.lowercased().contains(query)
            let matchesText: Bool
            switch field {
            case .all: matchesText = company || position
            case .company: matchesText = company
            case .position: matchesText = position
            }
            return matchesStatus && matchesText
        }

        return filtered.sorted {
            order == .newestFirst ? $0.applicationDate > $1.applicationDate
                                  : $0.applicationDate < $1.applicationDate
        }
    }

    // MARK: - Helpers

    private func followUpNotificationId(_ applicationId: String) -> String {
        "followup-\(applicationId)"
    }

    private func scheduleFollowUp(for application: JobApplication) {
        let id = followUpNotificationId(application.id)
        if let date = application.followUpDate {
            NotificationService.shared.schedule(
                id: id,
                title: "Follow up with \(application.companyName)",
                body: "Check on your \(application.position) application.",
                at: date)
        } else {
            NotificationService.shared.cancel(id: id)
        }
    }

    /// Runs a Firestore operation only when signed in with Firebase (not in Demo Mode).
    @MainActor
    private func persist(_ operation: (String) async throws -> Void) async {
        guard let session = session, !session.isDemo else { return }
        do {
            try await operation(session.uid)
        } catch {
            errorMessage = "Could not sync with the cloud: \(error.localizedDescription)"
        }
    }
}
