import Foundation
import FirebaseAuth
import FirebaseFirestore

private final class SentDoguinhoRequestListener: NSObject, ListenerRegistration {
    private var userListener: ListenerRegistration?
    private var requestListener: ListenerRegistration?
    private(set) var observedRequestId: String?

    deinit {
        remove()
    }

    func setUserListener(_ listener: ListenerRegistration) {
        userListener = listener
    }

    func replaceRequestListener(
        requestId: String?,
        with listener: ListenerRegistration?
    ) {
        requestListener?.remove()
        requestListener = listener
        observedRequestId = requestId
    }

    func remove() {
        userListener?.remove()
        requestListener?.remove()
        userListener = nil
        requestListener = nil
        observedRequestId = nil
    }
}

private final class EmptyDoguinhoRequestListener: NSObject, ListenerRegistration {
    func remove() {}
}

final class DoguinhoRequestService {
    private let db = Firestore.firestore()

    // MARK: - Pedido enviado (listener em tempo real)

    /// Observa o pedido mais recente registrado pelo remetente. O retorno deve
    /// ser mantido pela ViewModel e removido quando a tela deixar de precisar
    /// de atualizações em tempo real.
    func listenForSentRequest(
        senderUserId: String,
        onChange: @escaping (Result<DoguinhoRequest?, Error>) -> Void
    ) -> ListenerRegistration {
        let listener = SentDoguinhoRequestListener()

        guard Auth.auth().currentUser?.uid == senderUserId else {
            onChange(.failure(DoguinhoRequestServiceError.notAuthorized))
            return listener
        }

        let userReference = db.collection("users").document(senderUserId)

        let userListener = userReference.addSnapshotListener { [weak self, weak listener] snapshot, error in
            guard let self, let listener else { return }

            if let error {
                onChange(.failure(error))
                return
            }

            guard let snapshot, snapshot.exists else {
                onChange(.failure(DoguinhoRequestServiceError.notAuthorized))
                return
            }

            let requestId = snapshot.data()?["pendingDoguinhoRequestId"] as? String

            guard requestId != listener.observedRequestId else { return }

            guard let requestId else {
                listener.replaceRequestListener(requestId: nil, with: nil)
                onChange(.success(nil))
                return
            }

            let requestReference = self.db.collection("doguinhoRequests")
                .document(requestId)

            let requestListener = requestReference.addSnapshotListener { [weak self] snapshot, error in
                guard let self else { return }

                if let error {
                    onChange(.failure(error))
                    return
                }

                guard let snapshot, snapshot.exists else {
                    onChange(.success(nil))
                    return
                }

                do {
                    let request = try snapshot.data(as: DoguinhoRequest.self)

                    guard !self.requestHasExpired(request) else {
                        Task {
                            do {
                                _ = try await self.expireIfNeeded(
                                    requestId: request.id,
                                    currentUserId: senderUserId
                                )
                            } catch {
                                onChange(.failure(error))
                            }
                        }
                        return
                    }

                    onChange(.success(request))
                } catch {
                    onChange(.failure(error))
                }
            }

            listener.replaceRequestListener(
                requestId: requestId,
                with: requestListener
            )
        }

        listener.setUserListener(userListener)
        return listener
    }

    // MARK: - Pedido recebido (listener em tempo real)

    /// Observa o pedido pending destinado ao usuário atual. A interface ainda
    /// não usa este método: ele prepara a fonte de dados da modal da Fase 5.
    func listenForReceivedRequest(
        receiverUserId: String,
        onChange: @escaping (Result<DoguinhoRequest?, Error>) -> Void
    ) -> ListenerRegistration {
        guard Auth.auth().currentUser?.uid == receiverUserId else {
            onChange(.failure(DoguinhoRequestServiceError.notAuthorized))
            return EmptyDoguinhoRequestListener()
        }

        return db.collection("doguinhoRequests")
            .whereField("receiverUserId", isEqualTo: receiverUserId)
            .whereField("status", isEqualTo: DoguinhoRequestStatus.pending.rawValue)
            .limit(to: 1)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self else { return }

                if let error {
                    onChange(.failure(error))
                    return
                }

                guard let document = snapshot?.documents.first else {
                    onChange(.success(nil))
                    return
                }

                do {
                    let request = try document.data(as: DoguinhoRequest.self)

                    guard !self.requestHasExpired(request) else {
                        Task {
                            do {
                                _ = try await self.expireIfNeeded(
                                    requestId: request.id,
                                    currentUserId: receiverUserId
                                )
                            } catch {
                                onChange(.failure(error))
                            }
                        }
                        return
                    }

                    onChange(.success(request))
                } catch {
                    onChange(.failure(error))
                }
            }
    }

    // MARK: - Respostas e expiração

    /// Registra uma das três respostas permitidas. A transação confirma que o
    /// pedido ainda está pending e dentro do prazo antes de alterar o status.
    func respond(
        to requestId: String,
        with response: DoguinhoRequestStatus,
        receiverUserId: String
    ) async throws {
        guard Auth.auth().currentUser?.uid == receiverUserId else {
            throw DoguinhoRequestServiceError.notAuthorized
        }

        guard response == .accepted || response == .delayed || response == .declined else {
            throw DoguinhoRequestServiceError.invalidResponse
        }

        let requestReference = db.collection("doguinhoRequests").document(requestId)

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            db.runTransaction({ transaction, errorPointer -> Any? in
                do {
                    let snapshot = try transaction.getDocument(requestReference)

                    guard snapshot.exists, let data = snapshot.data() else {
                        throw DoguinhoRequestServiceError.requestNotFound
                    }

                    guard data["receiverUserId"] as? String == receiverUserId else {
                        throw DoguinhoRequestServiceError.notAuthorized
                    }

                    guard data["status"] as? String == DoguinhoRequestStatus.pending.rawValue else {
                        throw DoguinhoRequestServiceError.requestAlreadyResolved
                    }

                    guard let expiresAt = data["expiresAt"] as? Timestamp else {
                        throw DoguinhoRequestServiceError.requestNotFound
                    }

                    if expiresAt.dateValue() <= Date() {
                        transaction.updateData([
                            "status": DoguinhoRequestStatus.expired.rawValue
                        ], forDocument: requestReference)
                        return "expired"
                    }

                    transaction.updateData([
                        "status": response.rawValue,
                        "answeredAt": Timestamp(date: Date())
                    ], forDocument: requestReference)

                    return "responded"
                } catch {
                    errorPointer?.pointee = error as NSError
                    return nil
                }
            }, completion: { result, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if result as? String == "responded" {
                    continuation.resume()
                } else if result as? String == "expired" {
                    continuation.resume(throwing: DoguinhoRequestServiceError.requestExpired)
                } else {
                    continuation.resume(throwing: DoguinhoRequestServiceError.operationFailed)
                }
            })
        }
    }

    /// Marca o pedido como expired quando o prazo já passou. Retorna `true`
    /// somente quando esta chamada persistiu a expiração no Firestore.
    func expireIfNeeded(
        requestId: String,
        currentUserId: String
    ) async throws -> Bool {
        guard Auth.auth().currentUser?.uid == currentUserId else {
            throw DoguinhoRequestServiceError.notAuthorized
        }

        let requestReference = db.collection("doguinhoRequests").document(requestId)

        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Bool, Error>) in
            db.runTransaction({ transaction, errorPointer -> Any? in
                do {
                    let snapshot = try transaction.getDocument(requestReference)

                    guard snapshot.exists, let data = snapshot.data() else {
                        throw DoguinhoRequestServiceError.requestNotFound
                    }

                    let senderUserId = data["senderUserId"] as? String
                    let receiverUserId = data["receiverUserId"] as? String

                    guard currentUserId == senderUserId || currentUserId == receiverUserId else {
                        throw DoguinhoRequestServiceError.notAuthorized
                    }

                    guard data["status"] as? String == DoguinhoRequestStatus.pending.rawValue else {
                        return "unchanged"
                    }

                    guard let expiresAt = data["expiresAt"] as? Timestamp else {
                        throw DoguinhoRequestServiceError.requestNotFound
                    }

                    guard expiresAt.dateValue() <= Date() else {
                        return "unchanged"
                    }

                    transaction.updateData([
                        "status": DoguinhoRequestStatus.expired.rawValue
                    ], forDocument: requestReference)

                    return "expired"
                } catch {
                    errorPointer?.pointee = error as NSError
                    return nil
                }
            }, completion: { result, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if result as? String == "expired" {
                    continuation.resume(returning: true)
                } else if result as? String == "unchanged" {
                    continuation.resume(returning: false)
                } else {
                    continuation.resume(throwing: DoguinhoRequestServiceError.operationFailed)
                }
            })
        }
    }

    private func requestHasExpired(_ request: DoguinhoRequest) -> Bool {
        request.status == .pending && request.expiresAt.dateValue() <= Date()
    }

    func createRequest(
        senderUserId: String,
        receiverUserId: String,
        senderPetId: String,
        connectedUserId: String?
    ) async throws -> String {

        // 1. Validar o usuário autenticado
        guard let authenticatedUserId = Auth.auth().currentUser?.uid,
              authenticatedUserId == senderUserId else {
            throw DoguinhoRequestServiceError.notAuthorized
        }

        // 2. Validar o parceiro conectado
        guard let connectedUserId,
              connectedUserId == receiverUserId else {
            throw DoguinhoRequestServiceError.noActiveConnection
        }

        // 3. Preparar os documentos e o prazo
        let userRef = db.collection("users").document(senderUserId)
        let connectionRef = db.collection("connections").document(
            ConnectionService.connectionId(uid1: senderUserId, uid2: receiverUserId)
        )
        let senderPetRef = userRef.collection("pets").document(senderPetId)
        let requestRef = db.collection("doguinhoRequests").document()

        let now = Date()
        let expirationDate = now.addingTimeInterval(15 * 60)

        let newRequestData: [String: Any] = [
            "id": requestRef.documentID,
            "senderUserId": senderUserId,
            "receiverUserId": receiverUserId,
            "senderPetId": senderPetId,
            "status": DoguinhoRequestStatus.pending.rawValue,
            "createdAt": Timestamp(date: now),
            "answeredAt": NSNull(),
            "expiresAt": Timestamp(date: expirationDate)
        ]

        // 4. Verificar e criar dentro de uma transação
        return try await withCheckedThrowingContinuation { continuation in
            db.runTransaction({ transaction, errorPointer -> Any? in

                do {
                    let userSnapshot = try transaction.getDocument(userRef)

                    guard userSnapshot.exists else {
                        throw DoguinhoRequestServiceError.notAuthorized
                    }

                    guard userSnapshot.data()?["connectedUserId"] as? String == receiverUserId else {
                        throw DoguinhoRequestServiceError.noActiveConnection
                    }

                    let connectionSnapshot = try transaction.getDocument(connectionRef)
                    let connectionData = connectionSnapshot.data()
                    let connectionUserIds = connectionData?["userIds"] as? [String] ?? []

                    guard connectionData?["status"] as? String == UserConnectionStatus.active.rawValue,
                          connectionUserIds.contains(senderUserId),
                          connectionUserIds.contains(receiverUserId) else {
                        throw DoguinhoRequestServiceError.noActiveConnection
                    }

                    let senderPetSnapshot = try transaction.getDocument(senderPetRef)
                    guard senderPetSnapshot.exists else {
                        throw DoguinhoRequestServiceError.selectedPetUnavailable
                    }

                    let existingRequestId =
                        userSnapshot.data()?["pendingDoguinhoRequestId"] as? String

                    var existingRequestRef: DocumentReference?
                    var existingRequestSnapshot: DocumentSnapshot?

                    // Todas as leituras acontecem antes das gravações.
                    if let existingRequestId {
                        let ref = self.db.collection("doguinhoRequests")
                            .document(existingRequestId)

                        let snapshot = try transaction.getDocument(ref)
                        existingRequestRef = ref
                        existingRequestSnapshot = snapshot
                    }

                    if let snapshot = existingRequestSnapshot,
                       snapshot.exists,
                       let data = snapshot.data(),
                       let status = data["status"] as? String,
                       status == DoguinhoRequestStatus.pending.rawValue {

                        let expiresAt = data["expiresAt"] as? Timestamp

                        if let expiresAt, expiresAt.dateValue() > Date() {
                            throw DoguinhoRequestServiceError
                                .pendingRequestAlreadyExists
                        }

                        // O pedido anterior expirou.
                        if let existingRequestRef {
                            transaction.updateData([
                                "status": DoguinhoRequestStatus.expired.rawValue
                            ], forDocument: existingRequestRef)
                        }
                    }

                    // Criar o novo pedido e registrar seu ID no usuário.
                    transaction.setData(
                        newRequestData,
                        forDocument: requestRef
                    )

                    transaction.setData([
                        "pendingDoguinhoRequestId": requestRef.documentID
                    ], forDocument: userRef, merge: true)

                    return requestRef.documentID

                } catch {
                    errorPointer?.pointee = error as NSError
                    return nil
                }

            }, completion: { result, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let requestId = result as? String {
                    continuation.resume(returning: requestId)
                } else {
                    continuation.resume(
                        throwing: DoguinhoRequestServiceError.notAuthorized
                    )
                }
            })
        }
    }
}

enum DoguinhoRequestServiceError: LocalizedError {
    case notAuthorized
    case noActiveConnection
    case pendingRequestAlreadyExists
    case requestNotFound
    case requestAlreadyResolved
    case requestExpired
    case invalidResponse
    case selectedPetUnavailable
    case operationFailed

    var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return "Usuário não autorizado."
        case .noActiveConnection:
            return "Você precisa estar conectado ao destinatário."
        case .pendingRequestAlreadyExists:
            return "Você já tem um pedido pendente."
        case .requestNotFound:
            return "Pedido não encontrado."
        case .requestAlreadyResolved:
            return "Este pedido já foi respondido ou finalizado."
        case .requestExpired:
            return "Este pedido expirou antes da resposta."
        case .invalidResponse:
            return "Esta resposta não é válida para um pedido."
        case .selectedPetUnavailable:
            return "O doguinho selecionado não está disponível."
        case .operationFailed:
            return "Não foi possível concluir a operação. Tente novamente."
        }
    }
}
