import SwiftUI

/// A colored capsule label for an application status.
struct StatusBadge: View {
    let status: ApplicationStatus
    var showsIcon = false

    var body: some View {
        HStack(spacing: 4) {
            if showsIcon {
                Image(systemName: status.iconName)
                    .font(.caption2)
            }
            Text(status.rawValue)
                .font(.caption.weight(.semibold))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .foregroundColor(status.color)
        .background(status.color.opacity(0.14))
        .clipShape(Capsule())
    }
}

struct StatusBadge_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ForEach(ApplicationStatus.allCases) { StatusBadge(status: $0, showsIcon: true) }
        }
    }
}
