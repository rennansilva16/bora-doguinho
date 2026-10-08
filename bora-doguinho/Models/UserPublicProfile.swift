import Foundation
import FirebaseFirestore

/// Dados públicos mínimos de um usuário, legíveis por qualquer autenticado.
/// Não contém email, connectedUserId nem outros dados privados.
struct UserPublicProfile: Codable, Identifiable {
    let id: String
    let name: String
    let avatarURL: String
}
