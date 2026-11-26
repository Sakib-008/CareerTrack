import SwiftUI

/// Destinations that can be pushed onto a NavigationStack by value.
/// Used with NavigationLink(value:) and NavigationPath.append(_:).
enum AppRoute: Hashable {
    case applicationDetail(id: String)
    case history
    case analytics
}

/// Maps a route to its screen.
struct AppRouteView: View {
    let route: AppRoute

    var body: some View {
        switch route {
        case .applicationDetail(let id):
            ApplicationDetailView(applicationId: id)
        case .history:
            ApplicationHistoryView()
        case .analytics:
            AnalyticsView()
        }
    }
}

extension View {
    /// Registers AppRoute destinations once per NavigationStack.
    func withAppRoutes() -> some View {
        navigationDestination(for: AppRoute.self) { route in
            AppRouteView(route: route)
        }
    }
}
