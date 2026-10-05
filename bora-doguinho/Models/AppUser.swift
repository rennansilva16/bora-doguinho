import Foundation
import FirebaseFirestore

struct AppUser: Codable, Identifiable, Equatable {
    let id: String
    var name: String
    var email: String
    var avatarURL: String
    var activePetId: String
    var petSelectionMode: PetSelectionMode
    var connectedUserId: String?
    let createdAt: Timestamp
}

enum PetSelectionMode: String, Codable {
    case specific
    case random
}
