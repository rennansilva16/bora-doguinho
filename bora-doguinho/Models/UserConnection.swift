import Foundation
import FirebaseFirestore

struct UserConnection: Codable, Identifiable {
    let id: String
    let userIds: [String]
    var status: UserConnectionStatus
    let requestId: String
    let createdAt: Timestamp
}

enum UserConnectionStatus: String, Codable {
    case active
    case inactive
}
