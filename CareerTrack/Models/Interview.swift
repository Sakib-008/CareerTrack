import Foundation

enum InterviewType: String, Codable, CaseIterable, Identifiable {
    case online = "Online"
    case onSite = "On-site"
    case phone = "Phone"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .online: return "video.fill"
        case .onSite: return "building.2.fill"
        case .phone: return "phone.fill"
        }
    }
}

/// An interview, optionally linked to a JobApplication through `applicationId`.
/// `date` stores both the interview date and time.
struct Interview: Identifiable, Codable, Hashable {
    var id: String
    var applicationId: String?
    var company: String
    var position: String
    var date: Date
    var locationOrLink: String
    var type: InterviewType
    var preparationNotes: String
    var reminderDate: Date?
    var createdAt: Date

    init(id: String = UUID().uuidString,
         applicationId: String? = nil,
         company: String,
         position: String,
         date: Date,
         locationOrLink: String,
         type: InterviewType = .online,
         preparationNotes: String = "",
         reminderDate: Date? = nil,
         createdAt: Date = Date()) {
        self.id = id
        self.applicationId = applicationId
        self.company = company
        self.position = position
        self.date = date
        self.locationOrLink = locationOrLink
        self.type = type
        self.preparationNotes = preparationNotes
        self.reminderDate = reminderDate
        self.createdAt = createdAt
    }

    var isUpcoming: Bool { date >= Date() }

    /// "Soon" means the interview starts within the next 48 hours.
    var isSoon: Bool {
        let interval = date.timeIntervalSinceNow
        return interval >= 0 && interval <= 48 * 60 * 60
    }
}
