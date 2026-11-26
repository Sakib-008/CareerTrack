import Foundation

/// The student's career profile. One profile per user.
struct CareerProfile: Codable, Equatable {
    var fullName: String
    var email: String
    var phone: String
    var university: String
    var degree: String
    var graduationYear: String
    var skills: [String]
    var summary: String
    var workExperience: String

    static let empty = CareerProfile(fullName: "", email: "", phone: "", university: "",
                                     degree: "", graduationYear: "", skills: [],
                                     summary: "", workExperience: "")

    var initials: String {
        let parts = fullName.split(separator: " ").prefix(2)
        let letters = parts.compactMap { $0.first }.map { String($0) }.joined()
        return letters.isEmpty ? "?" : letters.uppercased()
    }

    var isEmpty: Bool { self == CareerProfile.empty }
}
