import FirebaseFirestore

struct DoguinhoRequest: Codable, Identifiable {
    let id: String
    let senderUserId: String
    let receiverUserId: String
    let senderPetId: String
    var status: DoguinhoRequestStatus
    let createdAt: Timestamp
    let answeredAt: Timestamp?
    let expiresAt: Timestamp
}

enum DoguinhoRequestStatus: String, Codable {
    case pending = "pending"
    case accepted = "accepted"
    case delayed = "delayed"
    case declined = "declined"
    case expired = "expired"
}
