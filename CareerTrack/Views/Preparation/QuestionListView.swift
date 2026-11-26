import SwiftUI

/// Questions and general tips for one category.
struct QuestionListView: View {
    let category: QuestionCategory
    @EnvironmentObject private var prep: PreparationViewModel

    var body: some View {
        List {
            Section("Tips for \(category.name)") {
                ForEach(category.tips, id: \.self) { tip in
                    Label(tip, systemImage: "lightbulb.fill")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                }
            }

            Section("Questions (\(category.questions.count))") {
                ForEach(category.questions) { question in
                    NavigationLink(value: question) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(question.question).font(.subheadline)
                                DifficultyLabel(difficulty: question.difficulty)
                            }
                            Spacer()
                            if prep.isFavorite(question) {
                                Image(systemName: "heart.fill").foregroundColor(.pink)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .navigationTitle(category.name)
    }
}

struct DifficultyLabel: View {
    let difficulty: InterviewQuestion.Difficulty

    private var color: Color {
        switch difficulty {
        case .easy: return .green
        case .medium: return .orange
        case .hard: return .red
        }
    }

    var body: some View {
        Text(difficulty.rawValue)
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .foregroundColor(color)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
    }
}
