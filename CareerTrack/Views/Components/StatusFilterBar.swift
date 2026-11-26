import SwiftUI

/// Horizontal chips for filtering by status. `nil` means "All".
/// Uses @Binding so the parent view owns the selected value.
struct StatusFilterBar: View {
    @Binding var selection: ApplicationStatus?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                chip(title: "All", color: Theme.navy, isSelected: selection == nil) {
                    selection = nil
                }
                ForEach(ApplicationStatus.allCases) { status in
                    chip(title: status.rawValue, color: status.color, isSelected: selection == status) {
                        selection = status
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 4)
        }
    }

    private func chip(title: String, color: Color, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) { action() }
        } label: {
            Text(title)
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .foregroundColor(isSelected ? .white : color)
                .background(isSelected ? color : color.opacity(0.12))
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
