import SwiftUI

/// Interview preparation: categories loaded from interview_questions.json.
struct InterviewPreparationView: View {
    @EnvironmentObject private var prep: PreparationViewModel

    var body: some View {
        NavigationStack {
            Group {
                if let error = prep.loadError {
                    EmptyStateView(icon: "exclamationmark.triangle", title: "Could not load questions",
                                   message: error, buttonTitle: "Try Again") { prep.reload() }
                } else if prep.categories.isEmpty {
                    ProgressView("Loading questions…")
                } else {
                    categoryList
                }
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Preparation")
            .navigationDestination(for: QuestionCategory.self) { category in
                QuestionListView(category: category)
            }
            .navigationDestination(for: InterviewQuestion.self) { question in
                QuestionDetailView(question: question, prep: prep)
            }
        }
        .onAppear { prep.loadIfNeeded() }
    }

    private var categoryList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("\(prep.categories.count) categories • \(prep.totalQuestionCount) questions")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                ForEach(prep.categories) { category in
                    NavigationLink(value: category) {
                        categoryRow(category)
                    }
                    .buttonStyle(.plain)
                }

                SectionHeader(title: "Favorites")
                    .padding(.top, 6)

                if prep.favoriteQuestions.isEmpty {
                    Text("Tap the heart on any question to save it here.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .cardStyle()
                } else {
                    ForEach(prep.favoriteQuestions) { question in
                        NavigationLink(value: question) {
                            HStack {
                                Image(systemName: "heart.fill").foregroundColor(.pink)
                                Text(question.question)
                                    .font(.subheadline)
                                    .multilineTextAlignment(.leading)
                                Spacer()
                                Image(systemName: "chevron.right").font(.caption).foregroundColor(.secondary)
                            }
                            .cardStyle()
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding()
        }
    }

    private func categoryRow(_ category: QuestionCategory) -> some View {
        HStack(spacing: 14) {
            Image(systemName: category.icon)
                .font(.title3)
                .foregroundColor(.white)
                .frame(width: 46, height: 46)
                .background(Theme.navy)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            VStack(alignment: .leading, spacing: 3) {
                Text(category.name).font(.headline)
                Text(category.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                Text("\(category.questions.count) questions")
                    .font(.caption2.weight(.semibold))
                    .foregroundColor(Theme.blue)
            }
            Spacer()
            Image(systemName: "chevron.right").foregroundColor(.secondary)
        }
        .cardStyle()
    }
}
