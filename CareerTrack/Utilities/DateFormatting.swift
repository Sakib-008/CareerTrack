import Foundation

extension Date {
    /// e.g. "12 Mar 2026"
    var shortDate: String { formatted(date: .abbreviated, time: .omitted) }

    /// e.g. "3:30 PM"
    var shortTime: String { formatted(date: .omitted, time: .shortened) }

    /// e.g. "12 Mar 2026 at 3:30 PM"
    var dateAndTime: String { formatted(date: .abbreviated, time: .shortened) }

    /// e.g. "in 2 days" / "3 days ago"
    var relativeDescription: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }

    /// e.g. "March 2026" (used for grouping history)
    var monthAndYear: String {
        formatted(.dateTime.month(.wide).year())
    }
}
