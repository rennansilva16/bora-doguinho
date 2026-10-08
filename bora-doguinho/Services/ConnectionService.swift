import Foundation
import FirebaseFirestore

enum ConnectionServiceError: LocalizedError {
    case userNotFound
    case alreadyConnected
    case cannotInviteSelf
    case duplicateRequest
    case requestNotFound
    case notAuthorized
    case operationFailed(String)

    var errorDescription: String? {
        switch self {
        case .userNotFound:
            return "Usuário não encontrado. Verifique o ID e tente novamente."
        case .alreadyConnected:
            return "Você já está conectado a alguém. Desconecte primeiro."
        case .cannotInviteSelf:
            return "Você não pode enviar um convite para si mesmo."
        case .duplicateRequest:
            return "Você já enviou um convite para esta pessoa."
        case .requestNotFound:
            return "Convite não encontrado."
        case .notAuthorized:
            return "Você não tem permissão para realizar esta ação."
        case .operationFailed:
            return "Não foi possível concluir essa ação. Tente novamente."
        }
    }
}

final class ConnectionService {
    private let db = Firestore.firestore()

    // MARK: - Helpers

    /// Retorna o connectionId ordenando os dois UIDs alfabeticamente.
    static func connectionId(uid1: String, uid2: String) -> String {
        [uid1, uid2].sorted().joined(separator: "_")
    }

    // MARK: - Busca de perfil público

    func fetchPublicProfile(id: String) async throws -> UserPublicProfile {
        let snap = try await db.collection("userPublicProfiles").document(id).getDocument()
        guard snap.exists else { throw ConnectionServiceError.userNotFound }
        return try snap.data(as: UserPublicProfile.self)
    }

    // MARK: - Enviar convite

    func sendInvite(from senderId: String, to recipientId: String) async throws {
        guard senderId != recipientId else { throw ConnectionServiceError.cannotInviteSelf }

        // Verificar se o destinatário existe
        let recipientSnap = try await db.collection("userPublicProfiles").document(recipientId).getDocument()
        guard recipientSnap.exists else { throw ConnectionServiceError.userNotFound }

        // Verificar se o remetente já está conectado
        let senderSnap = try await db.collection("users").document(senderId).getDocument()
        if let data = senderSnap.data(), let existing = data["connectedUserId"] as? String, !existing.isEmpty {
            throw ConnectionServiceError.alreadyConnected
        }

        // Verificar convite duplicado pendente
        let existing = try await db.collection("connectionRequests")
            .whereField("senderId", isEqualTo: senderId)
            .whereField("recipientId", isEqualTo: recipientId)
            .whereField("status", isEqualTo: "pending")
            .getDocuments()
        guard existing.documents.isEmpty else { throw ConnectionServiceError.duplicateRequest }

        // Criar convite
        let ref = db.collection("connectionRequests").document()
        try await ref.setData([
            "id": ref.documentID,
            "senderId": senderId,
            "recipientId": recipientId,
            "status": ConnectionRequestStatus.pending.rawValue,
            "createdAt": FieldValue.serverTimestamp()
        ])
    }

    // MARK: - Convites recebidos (listener em tempo real)

    func listenForReceivedRequests(
        recipientId: String,
        onChange: @escaping ([ConnectionRequest]) -> Void
    ) -> ListenerRegistration {
        db.collection("connectionRequests")
            .whereField("recipientId", isEqualTo: recipientId)
            .whereField("status", isEqualTo: "pending")
            .addSnapshotListener { snapshot, _ in
                guard let docs = snapshot?.documents else { return }
                let requests = docs.compactMap { try? $0.data(as: ConnectionRequest.self) }
                onChange(requests)
            }
    }

    // MARK: - Listener da conexão ativa (para o sender saber quando foi aceito)

    func listenForActiveConnection(
        userId: String,
        onChange: @escaping (UserConnection?) -> Void
    ) -> ListenerRegistration {
        db.collection("connections")
            .whereField("userIds", arrayContains: userId)
            .whereField("status", isEqualTo: "active")
            .addSnapshotListener { snapshot, _ in
                guard let doc = snapshot?.documents.first else {
                    onChange(nil)
                    return
                }
                onChange(try? doc.data(as: UserConnection.self))
            }
    }

    // MARK: - Aceitar convite

    /// O recipient executa uma transação atômica para aceitar e consolidar tudo,
    /// sem deixar janela de corrida para convites concorrentes.
    func acceptRequest(_ request: ConnectionRequest, currentUserId: String) async throws {
        guard request.recipientId == currentUserId else { throw ConnectionServiceError.notAuthorized }

        let connId = Self.connectionId(uid1: request.senderId, uid2: request.recipientId)

        // 1. Obter previamente as referências de convites reversos concorrentes (se existirem)
        let conflictingQuery = try await db.collection("connectionRequests")
            .whereField("senderId", isEqualTo: request.recipientId)
            .whereField("recipientId", isEqualTo: request.senderId)
            .whereField("status", isEqualTo: "pending")
            .getDocuments()
        let conflictingRefs = conflictingQuery.documents.map { $0.reference }

        let requestRef = db.collection("connectionRequests").document(request.id)
        let connRef = db.collection("connections").document(connId)
        let recipientRef = db.collection("users").document(request.recipientId)

        // 2. Executa a transação fortemente consistente
        let _: Any? = try await db.runTransaction { (transaction, errorPointer) -> Any? in
            let requestDoc: DocumentSnapshot
            do {
                requestDoc = try transaction.getDocument(requestRef)
            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }
            
            // Verificação de segurança de concorrência: o convite ainda está pendente?
            guard let status = requestDoc.data()?["status"] as? String else { return nil }
            if status != "pending" {
                // Outra ponta já resolveu a conexão (aceitou o convite reverso ou fechou este).
                // Finaliza atômica e silenciosamente de forma idempotente.
                return "ALREADY_HANDLED"
            }
            
            // Marca o convite oficial como aceito
            transaction.updateData(["status": ConnectionRequestStatus.accepted.rawValue], forDocument: requestRef)
            
            // Cria ou Reconecta a conexão existente
            transaction.setData([
                "id": connId,
                "userIds": [request.senderId, request.recipientId],
                "status": UserConnectionStatus.active.rawValue,
                "requestId": request.id,
                "createdAt": FieldValue.serverTimestamp()
            ], forDocument: connRef)
            
            // Atualiza o perfil local do recipient
            transaction.updateData(["connectedUserId": request.senderId], forDocument: recipientRef)
            
            // Trata os convites reversos dentro da MESMA transação
            for ref in conflictingRefs {
                do {
                    let doc = try transaction.getDocument(ref)
                    if let cStatus = doc.data()?["status"] as? String, cStatus == "pending" {
                        transaction.updateData(["status": ConnectionRequestStatus.closed.rawValue], forDocument: ref)
                    }
                } catch {
                    // Ignora silenciosamente
                }
            }
            
            return "SUCCESS"
        }
    }

    // MARK: - Recusar convite

    func declineRequest(_ request: ConnectionRequest, currentUserId: String) async throws {
        guard request.recipientId == currentUserId else { throw ConnectionServiceError.notAuthorized }
        try await db.collection("connectionRequests").document(request.id)
            .updateData(["status": ConnectionRequestStatus.declined.rawValue])
    }

    // MARK: - Atualizar connectedUserId do sender (chamado após listener detectar conexão ativa)

    /// O sender chama este método após o listener detectar um connections/ ativo.
    /// Neste ponto, o documento connections/ já existe e as Rules podem usar exists().
    func applySenderConnection(senderId: String, connectedUserId: String) async throws {
        try await db.collection("users").document(senderId)
            .updateData(["connectedUserId": connectedUserId])
    }

    // MARK: - Desconectar

    /// Batch de 2 operações:
    /// 1. connections/{id}.status = 'inactive'
    /// 2. users/{self}.connectedUserId = null
    ///
    /// O outro usuário atualiza o próprio connectedUserId via listener.
    func disconnect(userId: String, connectedUserId: String) async throws {
        let connId = Self.connectionId(uid1: userId, uid2: connectedUserId)
        let batch = db.batch()

        let connRef = db.collection("connections").document(connId)
        batch.updateData(["status": UserConnectionStatus.inactive.rawValue], forDocument: connRef)

        let userRef = db.collection("users").document(userId)
        batch.updateData(["connectedUserId": NSNull()], forDocument: userRef)

        try await batch.commit()
    }

    /// O outro usuário chama este após o listener detectar connections/ inativo.
    func applyPartnerDisconnection(userId: String) async throws {
        try await db.collection("users").document(userId)
            .updateData(["connectedUserId": NSNull()])
    }

    // MARK: - Internos

    // Removido closeConflictingRequests pois agora é feito de forma atômica no acceptRequest
}
