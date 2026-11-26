import Foundation
import FirebaseFirestore

/// Reads and writes user data in Cloud Firestore.
///
/// Structure:
///   users/{uid}/applications/{applicationId}
///   users/{uid}/interviews/{interviewId}
///   users/{uid}/profile/main
///
/// Models are converted with Codable: model -> JSON -> [String: Any] (and back).
/// Dates are stored as seconds since 1970 (numbers).
final class FirestoreService {
    static let shared = FirestoreService()
    private init() {}

    enum Collection: String {
        case applications
        case interviews
        case profile
    }

    private var db: Firestore { Firestore.firestore() }

    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        return encoder
    }()

    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        return decoder
    }()

    private func collection(_ collection: Collection, uid: String) -> CollectionReference {
        db.collection("users").document(uid).collection(collection.rawValue)
    }

    // MARK: - Generic list operations (applications & interviews)

    func fetchAll<T: Decodable>(_ type: T.Type, from collectionName: Collection, uid: String) async throws -> [T] {
        let snapshot = try await collection(collectionName, uid: uid).getDocuments()
        // Skip any document that cannot be decoded instead of failing the whole list.
        return snapshot.documents.compactMap { try? decode(type, from: $0.data()) }
    }

    func save<T: Encodable>(_ item: T, id: String, in collectionName: Collection, uid: String) async throws {
        let data = try encode(item)
        try await collection(collectionName, uid: uid).document(id).setData(data)
    }

    func delete(id: String, from collectionName: Collection, uid: String) async throws {
        try await collection(collectionName, uid: uid).document(id).delete()
    }

    // MARK: - Profile

    func fetchProfile(uid: String) async throws -> CareerProfile? {
        let snapshot = try await collection(.profile, uid: uid).document("main").getDocument()
        guard let data = snapshot.data() else { return nil }
        return try decode(CareerProfile.self, from: data)
    }

    func saveProfile(_ profile: CareerProfile, uid: String) async throws {
        try await save(profile, id: "main", in: .profile, uid: uid)
    }

    // MARK: - Codable <-> Firestore dictionary

    private func encode<T: Encodable>(_ item: T) throws -> [String: Any] {
        let data = try encoder.encode(item)
        guard let dictionary = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw NSError(domain: "CareerTrack", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "Could not convert data for saving."])
        }
        return dictionary
    }

    private func decode<T: Decodable>(_ type: T.Type, from dictionary: [String: Any]) throws -> T {
        // Guard against values JSON cannot represent (e.g. a Timestamp added manually in the console).
        guard JSONSerialization.isValidJSONObject(dictionary) else {
            throw NSError(domain: "CareerTrack", code: 2,
                          userInfo: [NSLocalizedDescriptionKey: "A stored document has an unsupported format."])
        }
        let data = try JSONSerialization.data(withJSONObject: dictionary)
        return try decoder.decode(type, from: data)
    }
}
