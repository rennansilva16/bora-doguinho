import Foundation
import FirebaseFirestore

struct PetCatalogItem: Codable, Identifiable {
    let id: String
    let name: String
    let imageName: String
    let createdAt: Timestamp
}
