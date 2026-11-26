import SwiftUI

/// One row in the application lists.
struct ApplicationCard: View {
    let application: JobApplication

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(String(application.companyName.prefix(1)).uppercased())
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 42, height: 42)
                .background(Theme.navy)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 4) {
                Text(application.position)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                Text(application.companyName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                HStack(spacing: 6) {
                    Label(application.location, systemImage: "mappin.and.ellipse")
                        .lineLimit(1)
                    Text("•")
                    Text(application.applicationDate.shortDate)
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }

            Spacer(minLength: 4)

            VStack(alignment: .trailing, spacing: 6) {
                StatusBadge(status: application.status)
                Text(application.jobType.rawValue)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .cardStyle()
    }
}

struct ApplicationCard_Previews: PreviewProvider {
    static var previews: some View {
        ApplicationCard(application: LocalDataService.sampleApplications()[0])
            .padding()
    }
}
