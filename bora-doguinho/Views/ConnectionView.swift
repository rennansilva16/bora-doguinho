import SwiftUI
import Combine
import FirebaseFirestore

@MainActor
final class ConnectionViewModel: ObservableObject {
    @Published var recipientIdInput: String = ""
    @Published var pendingRequests: [ConnectionRequest] = []
    @Published var partnerProfile: UserPublicProfile?
    @Published var isLoading = false
    @Published var isSending = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var showDisconnectConfirmation = false

    private let service = ConnectionService()
    private var requestsListener: ListenerRegistration?
    private var connectionListener: ListenerRegistration?

    // MARK: - Setup

    func setup(session: AuthSessionStore) {
        guard let user = session.currentUser else { return }
        startListeners(user: user, session: session)
    }

    func teardown() {
        requestsListener?.remove()
        connectionListener?.remove()
        requestsListener = nil
        connectionListener = nil
    }

    // MARK: - Listeners

    private func startListeners(user: AppUser, session: AuthSessionStore) {
        // Listener de convites recebidos
        requestsListener = service.listenForReceivedRequests(recipientId: user.id) { [weak self] requests in
            self?.pendingRequests = requests
        }

        // Listener da conexão ativa — usado pelo sender para saber quando foi aceito
        // e por ambos para detectar desconexão do parceiro
        connectionListener = service.listenForActiveConnection(userId: user.id) { [weak self] connection in
            guard let self else { return }
            Task { @MainActor in
                await self.handleConnectionChange(connection: connection, session: session)
            }
        }

        // Se já conectado, carrega o perfil do parceiro
        if let partnerId = user.connectedUserId {
            Task { await self.loadPartnerProfile(id: partnerId) }
        }
    }

    private func handleConnectionChange(connection: UserConnection?, session: AuthSessionStore) async {
        guard let user = session.currentUser else { return }

        if let connection {
            // Conexão ativa detectada
            let partnerId = connection.userIds.first { $0 != user.id } ?? ""

            // Se o sender ainda não tinha connectedUserId local, atualiza
            if user.connectedUserId == nil || user.connectedUserId != partnerId {
                do {
                    try await service.applySenderConnection(senderId: user.id, connectedUserId: partnerId)
                    session.updateConnection(connectedUserId: partnerId)
                } catch {
                    // Pode ter sido o recipient — connectedUserId já está setado
                }
            }

            await loadPartnerProfile(id: partnerId)
        } else {
            // Conexão inativa ou removida — parceiro pode ter desconectado
            if user.connectedUserId != nil {
                do {
                    try await service.applyPartnerDisconnection(userId: user.id)
                    session.updateConnection(connectedUserId: nil)
                    partnerProfile = nil
                } catch {
                    // Já pode estar null no Firestore
                }
            }
        }
    }

    private func loadPartnerProfile(id: String) async {
        partnerProfile = try? await service.fetchPublicProfile(id: id)
    }

    // MARK: - Ações

    func sendInvite(from userId: String) async {
        let target = recipientIdInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !target.isEmpty else {
            errorMessage = "Informe o ID do usuário."
            return
        }
        isSending = true
        errorMessage = nil
        successMessage = nil
        do {
            try await service.sendInvite(from: userId, to: target)
            successMessage = "Convite enviado!"
            recipientIdInput = ""
        } catch let e as ConnectionServiceError {
            errorMessage = e.localizedDescription
        } catch {
            errorMessage = "Não foi possível enviar o convite. Tente novamente."
        }
        isSending = false
    }

    func accept(request: ConnectionRequest, session: AuthSessionStore) async {
        guard let user = session.currentUser else { return }
        isLoading = true
        errorMessage = nil
        do {
            try await service.acceptRequest(request, currentUserId: user.id)
            session.updateConnection(connectedUserId: request.senderId)
            await loadPartnerProfile(id: request.senderId)
        } catch let e as ConnectionServiceError {
            errorMessage = e.localizedDescription
        } catch {
            errorMessage = "Não foi possível aceitar o convite. Tente novamente."
        }
        isLoading = false
    }

    func decline(request: ConnectionRequest, session: AuthSessionStore) async {
        guard let user = session.currentUser else { return }
        isLoading = true
        do {
            try await service.declineRequest(request, currentUserId: user.id)
        } catch {
            errorMessage = "Não foi possível recusar o convite. Tente novamente."
        }
        isLoading = false
    }

    func disconnect(session: AuthSessionStore) async {
        guard let user = session.currentUser, let partnerId = user.connectedUserId else { return }
        isLoading = true
        errorMessage = nil
        do {
            try await service.disconnect(userId: user.id, connectedUserId: partnerId)
            session.updateConnection(connectedUserId: nil)
            partnerProfile = nil
        } catch {
            errorMessage = "Não foi possível desconectar. Tente novamente."
        }
        isLoading = false
    }
}

// MARK: - View

struct ConnectionView: View {
    @EnvironmentObject var session: AuthSessionStore
    @StateObject private var viewModel = ConnectionViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if let user = session.currentUser {
                    if user.connectedUserId != nil {
                        connectedState
                    } else {
                        disconnectedState(userId: user.id)
                    }
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("Conexão")
            .navigationBarTitleDisplayMode(.inline)
        }
        .task {
            viewModel.setup(session: session)
        }
        .onDisappear {
            viewModel.teardown()
        }
        .alert("Desconectar?", isPresented: $viewModel.showDisconnectConfirmation) {
            Button("Cancelar", role: .cancel) {}
            Button("Desconectar", role: .destructive) {
                Task { await viewModel.disconnect(session: session) }
            }
        } message: {
            Text("Vocês deixarão de poder enviar solicitações um para o outro.")
        }
    }

    // MARK: - Estado: sem conexão

    private func disconnectedState(userId: String) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                // Enviar convite
                VStack(alignment: .leading, spacing: 12) {
                    Text("Conectar com alguém")
                        .font(.headline)

                    Text("Informe o ID do usuário para enviar um convite.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    HStack {
                        TextField("ID do usuário", text: $viewModel.recipientIdInput)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .padding(10)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 10))

                        Button {
                            Task { await viewModel.sendInvite(from: userId) }
                        } label: {
                            if viewModel.isSending {
                                ProgressView()
                                    .frame(width: 44, height: 44)
                            } else {
                                Image(systemName: "paperplane.fill")
                                    .foregroundStyle(.white)
                                    .frame(width: 44, height: 44)
                                    .background(Color.pink)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                        .disabled(viewModel.isSending || viewModel.recipientIdInput.trimmingCharacters(in: .whitespaces).isEmpty)
                    }

                    if let msg = viewModel.successMessage {
                        Label(msg, systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                            .font(.subheadline)
                    }
                    if let err = viewModel.errorMessage {
                        Label(err, systemImage: "exclamationmark.circle.fill")
                            .foregroundStyle(.red)
                            .font(.subheadline)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .shadow(color: .black.opacity(0.06), radius: 6, y: 2)

                // Seu ID (para compartilhar)
                if let user = session.currentUser {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Seu ID")
                            .font(.headline)

                        HStack {
                            Text(user.id)
                                .font(.system(.caption, design: .monospaced))
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                                .truncationMode(.middle)

                            Spacer()

                            Button {
                                UIPasteboard.general.string = user.id
                            } label: {
                                Image(systemName: "doc.on.doc")
                                    .foregroundStyle(.pink)
                            }
                        }
                        Text("Compartilhe seu ID para que outra pessoa possa conectar com você.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
                }

                // Convites recebidos
                if !viewModel.pendingRequests.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Convites recebidos")
                            .font(.headline)

                        ForEach(viewModel.pendingRequests) { request in
                            requestCard(request: request)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }

    private func requestCard(request: ConnectionRequest) -> some View {
        HStack(spacing: 12) {
            // Avatar placeholder
            Circle()
                .fill(Color.pink.opacity(0.15))
                .frame(width: 44, height: 44)
                .overlay(
                    Text(String(request.senderId.prefix(1)).uppercased())
                        .font(.headline)
                        .foregroundStyle(.pink)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text("Convite de:")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(request.senderId)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }

            Spacer()

            HStack(spacing: 8) {
                Button {
                    Task { await viewModel.decline(request: request, session: session) }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.gray)
                }

                Button {
                    Task { await viewModel.accept(request: request, session: session) }
                } label: {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.green)
                }
            }
            .disabled(viewModel.isLoading)
        }
        .padding(10)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Estado: conectado

    private var connectedState: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "heart.fill")
                .font(.system(size: 48))
                .foregroundStyle(.pink)

            if let partner = viewModel.partnerProfile {
                VStack(spacing: 8) {
                    Circle()
                        .fill(Color.pink.opacity(0.15))
                        .frame(width: 80, height: 80)
                        .overlay(
                            Text(String(partner.name.prefix(1)).uppercased())
                                .font(.largeTitle.bold())
                                .foregroundStyle(.pink)
                        )

                    Text(partner.name)
                        .font(.title2.bold())

                    Text(partner.id)
                        .font(.system(.caption, design: .monospaced))
                        .foregroundStyle(.secondary)
                }
            } else {
                ProgressView("Carregando parceiro...")
            }

            Text("Vocês estão conectados! ❤️")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if let err = viewModel.errorMessage {
                Label(err, systemImage: "exclamationmark.circle.fill")
                    .foregroundStyle(.red)
                    .font(.subheadline)
                    .padding(.horizontal)
            }

            Spacer()

            Button(role: .destructive) {
                viewModel.showDisconnectConfirmation = true
            } label: {
                HStack {
                    Image(systemName: "link.badge.minus")
                    Text("Desconectar")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray5))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal)
            .disabled(viewModel.isLoading)
        }
        .padding()
    }
}

#Preview {
    ConnectionView()
        .environmentObject(AuthSessionStore())
}
