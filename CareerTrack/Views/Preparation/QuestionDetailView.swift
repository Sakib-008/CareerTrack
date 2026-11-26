import SwiftUI

/// One question with its tip, key points and sample answer.
/// `prep` is passed in explicitly and observed with @ObservedObject,
/// so the heart button updates when favorites change.
struct QuestionDetailView: View {
    let question: InterviewQuestion
    @ObservedObject var prep: PreparationViewModel

    @State private var showAnswer = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        if let category = prep.category(containing: question) {
                            Text(category.name)
                                .font(.caption.weight(.semibold))
                                .foregroundColor(Theme.blue)
                        }
                        Spacer()
                        DifficultyLabel(difficulty: question.difficulty)
                    }
                    Text(question.question)
                        .font(.title3.bold())
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .cardStyle()

                VStack(alignment: .leading, spacing: 8) {
                    Label("Tip", systemImage: "lightbulb.fill")
                        .font(.headline)
                        .foregroundColor(.orange)
                    Text(question.tip).font(.body)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .cardStyle()

                VStack(alignment: .leading, spacing: 8) {
                    Label("Key points to cover", systemImage: "checklist")
                        .font(.headline)
                        .foregroundColor(Theme.navy)
                    ForEach(question.keyPoints, id: \.self) { point in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.subheadline)
                            Text(point).font(.subheadline)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .cardStyle()

                VStack(alignment: .leading, spacing: 8) {
                    Button {
                        withAnimation(.easeInOut) { showAnswer.toggle() }
                    } label: {
                        HStack {
                            Label("Sample answer", systemImage: "text.bubble.fill")
                                .font(.headline)
                            Spacer()
                            Image(systemName: showAnswer ? "chevron.up" : "chevron.down")
                        }
                        .foregroundColor(Theme.navy)
                    }
                    if showAnswer {
                        Text(question.sampleAnswer)
                            .font(.body)
                            .transition(.opacity)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .cardStyle()
            }
            .padding()
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle("Question")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    withAnimation { prep.toggleFavorite(question) }
                } label: {
                    Image(systemName: prep.isFavorite(question) ? "heart.fill" : "heart")
                        .foregroundColor(.pink)
                }
            }
        }
        // Hide the answer again when leaving, so it is fresh for the next practice round.
        .onDisappear { showAnswer = false }
    }
}
