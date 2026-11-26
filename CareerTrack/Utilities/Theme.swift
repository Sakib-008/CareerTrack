import SwiftUI

/// App-wide colors and the shared card style.
enum Theme {
    static let navy = Color(red: 0.11, green: 0.20, blue: 0.42)
    static let blue = Color(red: 0.20, green: 0.42, blue: 0.85)
    static let background = Color(.systemGroupedBackground)
    static let card = Color(.secondarySystemGroupedBackground)
    static let soon = Color.orange
}

extension ApplicationStatus {
    var color: Color {
        switch self {
        case .applied: return Theme.blue
        case .shortlisted: return .purple
        case .interview: return .orange
        case .rejected: return .red
        case .accepted: return .green
        }
    }
}

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Theme.card)
            .cornerRadius(14)
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

extension View {
    func cardStyle() -> some View { modifier(CardStyle()) }
}
