import Foundation

/// Loads interview questions from JSON and keeps track of favorite questions.
final class PreparationViewModel: ObservableObject {
    @Published private(set) var categories: [QuestionCategory] = []
    @Published private(set) var loadError: String?
    @Published private(set) var favoriteIDs: Set<String>

    private let favoritesKey = "favoriteQuestionIDs"

    init() {
        let saved = UserDefaults.standard.stringArray(forKey: favoritesKey) ?? []
        favoriteIDs = Set(saved)
    }

    func loadIfNeeded() {
        guard categories.isEmpty else { return }
        reload()
    }

    func reload() {
        do {
            categories = try QuestionBankService.loadQuestionBank().categories
            loadError = nil
        } catch {
            categories = []
            loadError = error.localizedDescription
        }
    }

    var totalQuestionCount: Int {
        categories.reduce(0) { $0 + $1.questions.count }
    }

    // MARK: - Favorites (saved on the device with UserDefaults)

    func isFavorite(_ question: InterviewQuestion) -> Bool {
        favoriteIDs.contains(question.id)
    }

    func toggleFavorite(_ question: InterviewQuestion) {
        if favoriteIDs.contains(question.id) {
            favoriteIDs.remove(question.id)
        } else {
            favoriteIDs.insert(question.id)
        }
        UserDefaults.standard.set(Array(favoriteIDs), forKey: favoritesKey)
    }

    var favoriteQuestions: [InterviewQuestion] {
        categories.flatMap { $0.questions }.filter { favoriteIDs.contains($0.id) }
    }

    func category(containing question: InterviewQuestion) -> QuestionCategory? {
        categories.first { category in category.questions.contains { $0.id == question.id } }
    }
}
