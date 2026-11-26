import Foundation

/// Root object of interview_questions.json.
/// JSON shape: { "version": 1, "categories": [ { ..., "questions": [ {...} ] } ] }
struct QuestionBank: Decodable {
    let version: Int
    let categories: [QuestionCategory]
}

/// A category such as "HR Questions" (nested inside QuestionBank).
struct QuestionCategory: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let icon: String
    let description: String
    let tips: [String]
    let questions: [InterviewQuestion]
}

/// A single question (nested inside QuestionCategory).
struct InterviewQuestion: Codable, Identifiable, Hashable {
    let id: String
    let question: String
    let difficulty: Difficulty
    let tip: String
    let sampleAnswer: String
    let keyPoints: [String]

    enum Difficulty: String, Codable {
        case easy = "Easy"
        case medium = "Medium"
        case hard = "Hard"
    }
}
