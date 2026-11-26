import SwiftUI

/// Reminds the user that Demo Mode data stays on the device only.
struct DemoModeBanner: View {
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "info.circle.fill")
            Text("Demo Mode — sample data is local only and is not saved to Firebase.")
                .font(.caption)
        }
        .foregroundColor(.orange)
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.orange.opacity(0.12))
        .cornerRadius(10)
    }
}
