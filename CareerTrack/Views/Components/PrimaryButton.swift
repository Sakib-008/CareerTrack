import SwiftUI

/// Full-width navy button that can show a loading spinner.
struct PrimaryButton: View {
    let title: String
    var icon: String?
    var isLoading = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else if let icon = icon {
                    Image(systemName: icon)
                }
                Text(title)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .foregroundColor(.white)
            .background(Theme.navy.opacity(isLoading ? 0.7 : 1))
            .cornerRadius(12)
        }
        .disabled(isLoading)
    }
}
