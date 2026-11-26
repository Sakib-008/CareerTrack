import SwiftUI

/// One interview row. Interviews within 48 hours are highlighted in orange.
struct InterviewCard: View {
    let interview: Interview

    var body: some View {
        HStack(spacing: 12) {
            VStack(spacing: 2) {
                Text(interview.date.formatted(.dateTime.day()))
                    .font(.title3.bold())
                Text(interview.date.formatted(.dateTime.month(.abbreviated)))
                    .font(.caption.weight(.semibold))
                    .textCase(.uppercase)
            }
            .foregroundColor(interview.isSoon ? Theme.soon : Theme.navy)
            .frame(width: 52, height: 56)
            .background((interview.isSoon ? Theme.soon : Theme.navy).opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(interview.company)
                        .font(.headline)
                        .lineLimit(1)
                    if interview.isSoon {
                        Text("SOON")
                            .font(.caption2.bold())
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Theme.soon)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }
                }
                Text(interview.position)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                Label("\(interview.date.shortTime) • \(interview.type.rawValue)",
                      systemImage: interview.type.iconName)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .cardStyle()
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(interview.isSoon ? Theme.soon : Color.clear, lineWidth: 1.5)
        )
    }
}

struct InterviewCard_Previews: PreviewProvider {
    static var previews: some View {
        InterviewCard(interview: LocalDataService.sampleInterviews()[0])
            .padding()
    }
}
