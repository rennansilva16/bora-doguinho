import Foundation
import FirebaseFirestore

/// A pet provisioned to one specific account. The global catalog and Storage URLs
/// are intentionally introduced in Phase 3.
struct UserPet: Codable, Identifiable {
    let id: String
    let name: String
    let createdAt: Timestamp
}
