import Foundation
import FirebaseFirestore

enum UserServiceError: LocalizedError {
    case profileNotFound

    var errorDescription: String? {
        switch self {
        case .profileNotFound:
            return "Não foi possível encontrar o perfil desta conta."
        }
    }
}

final class UserService {
    func createProfile(id: String, name: String, email: String) async throws -> AppUser {
        let user = AppUser(
            id: id,
            name: name,
            email: email,
            avatarURL: "",
            activePetId: "harry",
            petSelectionMode: .specific,
            connectedUserId: nil,
            createdAt: Timestamp(date: Date())
        )

        let database = Firestore.firestore()
        let batch = database.batch()
        let userReference = database.collection("users").document(id)
        batch.setData([
            "id": user.id,
            "name": user.name,
            "email": user.email,
            "avatarURL": user.avatarURL,
            "activePetId": user.activePetId,
            "petSelectionMode": user.petSelectionMode.rawValue,
            "connectedUserId": NSNull(),
            "createdAt": user.createdAt
        ], forDocument: userReference)

        for pet in ["harry": "Harry", "pandora": "Pandora"] {
            batch.setData([
                "id": pet.key,
                "name": pet.value,
                "createdAt": user.createdAt
            ], forDocument: userReference.collection("pets").document(pet.key))
        }

        try await batch.commit()
        return user
    }

    func fetchProfile(id: String) async throws -> AppUser {
        let snapshot = try await Firestore.firestore().collection("users").document(id).getDocument()
        guard snapshot.exists else {
            throw UserServiceError.profileNotFound
        }
        return try snapshot.data(as: AppUser.self)
    }
}
