import Foundation
import FirebaseFirestore

struct ConnectionRequest: Codable, Identifiable {
    let id: String
    let senderId: String
    let recipientId: String
    var status: ConnectionRequestStatus
    let createdAt: Timestamp
}

enum ConnectionRequestStatus: String, Codable {
    case pending
    case accepted
    case declined
    case closed
}
