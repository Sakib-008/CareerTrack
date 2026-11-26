import Foundation

/// Owns interview data and interview reminders.
final class InterviewViewModel: ObservableObject {
    @Published private(set) var interviews: [Interview] = []
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    private var session: UserSession?

    @MainActor
    func load(for session: UserSession) async {
        self.session = session
        interviews = []

        if session.isDemo {
            interviews = LocalDataService.sampleInterviews()
            return
        }

        isLoading = true
        do {
            interviews = try await FirestoreService.shared.fetchAll(Interview.self,
                                                                    from: .interviews, uid: session.uid)
        } catch {
            errorMessage = "Could not load interviews: \(error.localizedDescription)"
        }
        isLoading = false
    }

    @MainActor
    func save(_ interview: Interview) async {
        if let index = interviews.firstIndex(where: { $0.id == interview.id }) {
            interviews[index] = interview
        } else {
            interviews.append(interview)
        }
        scheduleReminder(for: interview)

        await persist { uid in
            try await FirestoreService.shared.save(interview, id: interview.id, in: .interviews, uid: uid)
        }
    }

    @MainActor
    func delete(_ interview: Interview) async {
        interviews.removeAll { $0.id == interview.id }
        NotificationService.shared.cancel(id: reminderId(interview.id))

        await persist { uid in
            try await FirestoreService.shared.delete(id: interview.id, from: .interviews, uid: uid)
        }
    }

    /// Removes every interview linked to a deleted application.
    @MainActor
    func deleteInterviews(forApplication applicationId: String) async {
        for interview in linkedInterviews(applicationId: applicationId) {
            await delete(interview)
        }
    }

    // MARK: - Queries

    /// Future interviews, soonest first.
    var upcomingInterviews: [Interview] {
        interviews.filter { $0.isUpcoming }.sorted { $0.date < $1.date }
    }

    /// Past interviews, most recent first.
    var pastInterviews: [Interview] {
        interviews.filter { !$0.isUpcoming }.sorted { $0.date > $1.date }
    }

    func linkedInterviews(applicationId: String) -> [Interview] {
        interviews.filter { $0.applicationId == applicationId }.sorted { $0.date < $1.date }
    }

    // MARK: - Helpers

    private func reminderId(_ interviewId: String) -> String {
        "interview-\(interviewId)"
    }

    private func scheduleReminder(for interview: Interview) {
        let id = reminderId(interview.id)
        if let date = interview.reminderDate {
            NotificationService.shared.schedule(
                id: id,
                title: "Interview with \(interview.company)",
                body: "\(interview.position) • \(interview.date.dateAndTime)",
                at: date)
        } else {
            NotificationService.shared.cancel(id: id)
        }
    }

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
