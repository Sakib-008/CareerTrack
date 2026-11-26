import SwiftUI

/// Statistics calculated from the user's real application and interview data.
/// Charts are drawn with plain SwiftUI shapes (no chart library).
struct AnalyticsView: View {
    @EnvironmentObject private var applications: ApplicationViewModel
    @EnvironmentObject private var interviews: InterviewViewModel

    /// Bars grow from zero when the screen appears.
    @State private var animateBars = false

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    private var total: Int { applications.totalCount }

    /// Applications that reached the interview stage: status Interview or Accepted,
    /// or with at least one interview logged.
    private var reachedInterviewCount: Int {
        applications.applications.filter { app in
            app.status == .interview || app.status == .accepted
                || !interviews.linkedInterviews(applicationId: app.id).isEmpty
        }.count
    }

    private var interviewConversionRate: Double {
        total == 0 ? 0 : Double(reachedInterviewCount) / Double(total)
    }

    private var acceptanceRate: Double {
        total == 0 ? 0 : Double(applications.count(for: .accepted)) / Double(total)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if total == 0 {
                    EmptyStateView(icon: "chart.bar", title: "No data yet",
                                   message: "Analytics will appear after you add applications.")
                        .cardStyle()
                }

                LazyVGrid(columns: columns, spacing: 12) {
                    StatCard(title: "Total", value: "\(total)", icon: "tray.full.fill", color: Theme.navy)
                    ForEach(ApplicationStatus.allCases) { status in
                        StatCard(title: status.rawValue, value: "\(applications.count(for: status))",
                                 icon: status.iconName, color: status.color)
                    }
                }

                SectionHeader(title: "Success Rates")
                HStack(spacing: 12) {
                    RateRing(title: "Interview conversion", value: interviewConversionRate,
                             color: .orange, animate: animateBars)
                    RateRing(title: "Acceptance rate", value: acceptanceRate,
                             color: .green, animate: animateBars)
                }

                SectionHeader(title: "Status Distribution")
                VStack(spacing: 12) {
                    ForEach(ApplicationStatus.allCases) { status in
                        HorizontalBar(label: status.rawValue,
                                      count: applications.count(for: status),
                                      total: total,
                                      color: status.color,
                                      animate: animateBars)
                    }
                }
                .cardStyle()

                SectionHeader(title: "Job Types")
                VStack(spacing: 12) {
                    ForEach(JobType.allCases) { type in
                        HorizontalBar(label: type.rawValue,
                                      count: applications.count(for: type),
                                      total: total,
                                      color: Theme.blue,
                                      animate: animateBars)
                    }
                }
                .cardStyle()

                Text("Interview conversion = applications that reached the interview stage (status Interview/Accepted or an interview logged) ÷ total. Acceptance rate = accepted ÷ total.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle("Analytics")
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) { animateBars = true }
        }
        .onDisappear { animateBars = false }
    }
}

/// A labeled horizontal progress bar drawn with rectangles.
struct HorizontalBar: View {
    let label: String
    let count: Int
    let total: Int
    let color: Color
    let animate: Bool

    private var fraction: CGFloat {
        total == 0 ? 0 : CGFloat(count) / CGFloat(total)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label).font(.subheadline)
                Spacer()
                Text("\(count) • \(Int((fraction * 100).rounded()))%")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.secondary)
            }
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule().fill(color.opacity(0.12))
                    Capsule().fill(color)
                        .frame(width: geometry.size.width * (animate ? fraction : 0))
                }
            }
            .frame(height: 10)
        }
    }
}

/// A circular percentage indicator drawn with Circle().trim.
struct RateRing: View {
    let title: String
    let value: Double
    let color: Color
    let animate: Bool

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.15), lineWidth: 10)
                Circle()
                    .trim(from: 0, to: animate ? CGFloat(value) : 0)
                    .stroke(color, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Text("\(Int((value * 100).rounded()))%")
                    .font(.title3.bold())
            }
            .frame(width: 90, height: 90)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .cardStyle()
    }
}
