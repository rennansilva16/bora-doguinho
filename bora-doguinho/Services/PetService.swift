import Foundation
import FirebaseFirestore

final class PetService {
    private let db = Firestore.firestore()
    
    func fetchCatalog() async throws -> [PetCatalogItem] {
        let snapshot = try await db.collection("pets").getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: PetCatalogItem.self) }
    }
    
    func fetchUserPets(userId: String) async throws -> [UserPet] {
        let snapshot = try await db.collection("users").document(userId).collection("pets").getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: UserPet.self) }
    }
    
    func updatePetSelection(userId: String, activePetId: String, mode: PetSelectionMode) async throws {
        try await db.collection("users").document(userId).updateData([
            "activePetId": activePetId,
            "petSelectionMode": mode.rawValue
        ])
    }
}
