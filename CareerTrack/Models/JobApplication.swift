import Foundation

/// The five stages an application can be in.
enum ApplicationStatus: String, Codable, CaseIterable, Identifiable {
    case applied = "Applied"
    case shortlisted = "Shortlisted"
    case interview = "Interview"
    case rejected = "Rejected"
    case accepted = "Accepted"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .applied: return "paperplane.fill"
        case .shortlisted: return "star.fill"
        case .interview: return "person.2.fill"
        case .rejected: return "xmark.circle.fill"
        case .accepted: return "checkmark.seal.fill"
        }
    }
}

enum JobType: String, Codable, CaseIterable, Identifiable {
    case internship = "Internship"
    case fullTime = "Full-time"
    case partTime = "Part-time"

    var id: String { rawValue }
}

/// A single job or internship application.
struct JobApplication: Identifiable, Codable, Hashable {
    var id: String
    var companyName: String
    var position: String
    var jobType: JobType
    var status: ApplicationStatus
    var applicationDate: Date
    var location: String
    var jobURL: String?
    var salary: String?
    var notes: String
    var followUpDate: Date?
    var createdAt: Date
    var updatedAt: Date

    init(id: String = UUID().uuidString,
         companyName: String,
         position: String,
         jobType: JobType = .internship,
         status: ApplicationStatus = .applied,
         applicationDate: Date = Date(),
         location: String,
         jobURL: String? = nil,
         salary: String? = nil,
         notes: String = "",
         followUpDate: Date? = nil,
         createdAt: Date = Date(),
         updatedAt: Date = Date()) {
        self.id = id
        self.companyName = companyName
        self.position = position
        self.jobType = jobType
        self.status = status
        self.applicationDate = applicationDate
        self.location = location
        self.jobURL = jobURL
        self.salary = salary
        self.notes = notes
        self.followUpDate = followUpDate
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    /// A valid URL for the job posting, if one was entered.
    var validJobURL: URL? {
        guard let text = jobURL?.trimmingCharacters(in: .whitespaces), !text.isEmpty else { return nil }
        let withScheme = text.lowercased().hasPrefix("http") ? text : "https://\(text)"
        return URL(string: withScheme)
    }

    /// True when a follow-up date is set and it is today or later.
    var hasUpcomingFollowUp: Bool {
        guard let followUpDate = followUpDate else { return false }
        return followUpDate >= Calendar.current.startOfDay(for: Date())
    }
}
