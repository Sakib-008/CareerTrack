import Foundation

enum QuestionBankError: LocalizedError {
    case fileNotFound(String)
    case unreadable(String)
    case invalidFormat(String)

    var errorDescription: String? {
        switch self {
        case .fileNotFound(let name):
            return "The file \(name).json was not found in the app bundle."
        case .unreadable(let reason):
            return "The question file could not be read: \(reason)"
        case .invalidFormat(let reason):
            return "The question file has an invalid format: \(reason)"
        }
    }
}

/// Loads interview questions from the bundled JSON file using JSONDecoder.
enum QuestionBankService {
    static let fileName = "interview_questions"

    static func loadQuestionBank(bundle: Bundle = .main) throws -> QuestionBank {
        guard let url = bundle.url(forResource: fileName, withExtension: "json") else {
            throw QuestionBankError.fileNotFound(fileName)
        }

        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch {
            throw QuestionBankError.unreadable(error.localizedDescription)
        }

        do {
            return try JSONDecoder().decode(QuestionBank.self, from: data)
        } catch let DecodingError.keyNotFound(key, _) {
            throw QuestionBankError.invalidFormat("missing key '\(key.stringValue)'")
        } catch let DecodingError.typeMismatch(_, context) {
            throw QuestionBankError.invalidFormat("wrong type at \(path(context))")
        } catch let DecodingError.valueNotFound(_, context) {
            throw QuestionBankError.invalidFormat("missing value at \(path(context))")
        } catch let DecodingError.dataCorrupted(context) {
            throw QuestionBankError.invalidFormat(context.debugDescription)
        } catch {
            throw QuestionBankError.invalidFormat(error.localizedDescription)
        }
    }

    private static func path(_ context: DecodingError.Context) -> String {
        let keys = context.codingPath.map { $0.stringValue }.joined(separator: ".")
        return keys.isEmpty ? "root" : keys
    }
}
