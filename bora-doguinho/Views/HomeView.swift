import SwiftUI
import Combine
import FirebaseFirestore

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var activePetImageName: String?
    @Published private(set) var activePetId: String?
    @Published private(set) var sentRequest: DoguinhoRequest?
    @Published private(set) var receivedRequest: DoguinhoRequest?
    @Published var partnerProfile: UserPublicProfile?
    @Published private(set) var isSendingRequest = false
    @Published var requestErrorMessage: String?
    
    private let petService = PetService()
    private let connectionService = ConnectionService()
    private let doguinhoRequestService = DoguinhoRequestService()
    private var sentRequestListener: ListenerRegistration?
    private var receivedRequestListener: ListenerRegistration?

    deinit {
        sentRequestListener?.remove()
        receivedRequestListener?.remove()
    }
    
    func loadActivePet(for user: AppUser) async {
        do {
            let userPets = try await petService.fetchUserPets(userId: user.id)
            let catalog = try await petService.fetchCatalog()
            let imageNamesByPetId = Dictionary(
                uniqueKeysWithValues: catalog.map { ($0.id, $0.imageName) }
            )

            petImageNamesById = imageNamesByPetId
            
            var chosenPetId: String?
            
            if user.petSelectionMode == .random, !userPets.isEmpty {
                chosenPetId = userPets.randomElement()?.id
            } else if userPets.contains(where: { $0.id == user.activePetId }) {
                chosenPetId = user.activePetId
            }
            
            activePetId = chosenPetId

            if let catalogItem = catalog.first(where: { $0.id == chosenPetId }) {
                self.activePetImageName = catalogItem.imageName
            }
        } catch {
            activePetId = nil
            petImageNamesById = [:]
            print("Erro ao carregar pet ativo: \(error.localizedDescription)")
        }
    }

    @Published private var petImageNamesById: [String: String] = [:]

    var displayedPetImageName: String? {
        if let receivedRequest {
            return petImageNamesById[receivedRequest.senderPetId]
        }
        if let sentRequest {
            return petImageNamesById[sentRequest.senderPetId]
        }
        return activePetImageName
    }

    func startObservingSentRequest(for userId: String) {
        sentRequestListener?.remove()

        sentRequestListener = doguinhoRequestService.listenForSentRequest(
            senderUserId: userId
        ) { [weak self] result in
            Task { @MainActor in
                switch result {
                case .success(let request):
                    self?.sentRequest = request
                case .failure(let error):
                    // A criação continua exibindo erros ao usuário. Para o
                    // listener, preservar a última tela evita apagar a Home
                    // apenas por uma falha temporária de rede.
                    print("Erro ao observar pedido enviado: \(error.localizedDescription)")
                }
            }
        }
    }

    func startObservingReceivedRequest(for userId: String) {
        receivedRequestListener?.remove()

        receivedRequestListener = doguinhoRequestService.listenForReceivedRequest(
            receiverUserId: userId
        ) { [weak self] result in
            Task { @MainActor in
                switch result {
                case .success(let request):
                    self?.receivedRequest = request
                case .failure(let error):
                    // Uma falha transitória não transforma o último pedido
                    // observado em respondido ou expirado na interface.
                    print("Erro ao observar pedido recebido: \(error.localizedDescription)")
                }
            }
        }
    }

    func stopObservingSentRequest() {
        sentRequestListener?.remove()
        receivedRequestListener?.remove()
        sentRequestListener = nil
        receivedRequestListener = nil
        sentRequest = nil
        receivedRequest = nil
    }

    func loadPartner(for user: AppUser) async {
        guard let partnerId = user.connectedUserId else {
            self.partnerProfile = nil
            return
        }
        
        do {
            self.partnerProfile = try await connectionService.fetchPublicProfile(id: partnerId)
        } catch {
            print("Erro ao carregar perfil do parceiro: \(error.localizedDescription)")
        }
    }

    /// A View só apresenta o resultado; a validação e a gravação ficam no
    /// serviço para que não possam ser contornadas por outro ponto da interface.
    func createDoguinhoRequest(for user: AppUser) async -> Bool {
        guard !isSendingRequest else { return false }

        guard let receiverUserId = user.connectedUserId else {
            requestErrorMessage = "Conecte-se ao seu parceiro antes de enviar uma solicitação."
            return false
        }

        guard let activePetId else {
            requestErrorMessage = "Escolha um doguinho disponível antes de enviar a solicitação."
            return false
        }

        isSendingRequest = true
        defer { isSendingRequest = false }

        do {
            _ = try await doguinhoRequestService.createRequest(
                senderUserId: user.id,
                receiverUserId: receiverUserId,
                senderPetId: activePetId,
                connectedUserId: user.connectedUserId
            )
            return true
        } catch {
            requestErrorMessage = error.localizedDescription
            return false
        }
    }

    func respond(to request: DoguinhoRequest, with response: DoguinhoRequestStatus, userId: String) async throws {
        try await doguinhoRequestService.respond(
            to: request.id,
            with: response,
            receiverUserId: userId
        )
    }
}

enum HomeVisualState {
    case noConnection
    case available
    case delivering
    case returning
    case received
    case expired

    var message: String {
        switch self {
        case .noConnection:
            return "🔗 Conecte-se ao seu parceiro para começar."
        case .available:
            return "🐶 Seu doguinho está pronto para levar um convite!"
        case .delivering:
            return "🐶 Estou levando sua solicitação!"
        case .returning:
            return "🐶 Voltei! ❤️"
        case .received:
            return "🐶 Você recebeu uma solicitação!"
        case .expired:
            return "🥺 A mensagem não foi respondida. Tente solicitar novamente."
        }
    }

    var isConnected: Bool { self != .noConnection }
}

struct HomeView: View {
    @EnvironmentObject var session: AuthSessionStore
    @StateObject private var viewModel = HomeViewModel()
    @State private var isShowingMenu = false
    @State private var visualState: HomeVisualState
    @State private var isShowingRequestModal = false
    @State private var presentedRequestIds: Set<String> = []

    init(visualState: HomeVisualState = .available) {
        _visualState = State(initialValue: visualState)
    }

    private var displayedVisualState: HomeVisualState {
        if viewModel.receivedRequest != nil {
            return .received
        }

        guard let request = viewModel.sentRequest else { return visualState }

        switch request.status {
        case .pending:
            return .delivering
        case .expired:
            return .expired
        case .accepted, .delayed, .declined:
            return .returning
        }
    }

    var body: some View {
        HStack(spacing: 0) {

            // Side menu
            if isShowingMenu {
                SideMenuView(isShowing: $isShowingMenu)
                    .frame(width: 200)
                    .shadow(radius: 4)
            }

            // Home
            VStack(spacing: 0) {

                // Header
                HStack {
                    // Menu
                    Button {
                        isShowingMenu.toggle()
                    } label: {
                        Image(systemName: "line.3.horizontal")
                            .font(.title2)
                            .frame(width: 44, height: 44)
                    }

                    Spacer()

                    // Casal / Usuário
                    HStack(spacing: 8) {
                        if let user = session.currentUser {
                            let firstName = user.name.components(separatedBy: " ").first ?? ""
                            avatar(initials: String(firstName.prefix(1)).uppercased(), color: .pink)
                            Text(firstName)
                                .font(.headline)

                            if user.connectedUserId != nil {
                                Image(systemName: "link")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)

                                if let partner = viewModel.partnerProfile {
                                    let partnerFirstName = partner.name.components(separatedBy: " ").first ?? ""
                                    avatar(initials: String(partnerFirstName.prefix(1)).uppercased(), color: .purple)
                                    Text(partnerFirstName)
                                        .font(.headline)
                                } else {
                                    ProgressView()
                                        .frame(width: 24, height: 24)
                                }
                            }
                        }
                    }

                    Spacer()

                    // Espaço para manter o casal realmente centralizado
                    Color.clear
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal, 8)

                // Indicador semanal
                HStack(spacing: 12) {
                    ForEach(
                        Array(zip(
                            ["D", "S", "T", "Q", "Q", "S", "S"],
                            [true, true, false, false, true, false, false]
                        )),
                        id: \.0
                    ) { day, isActive in
                        VStack(spacing: 6) {
                            Text(day)
                                .font(.caption)
                                .fontWeight(.medium)

                            Circle()
                                .fill(
                                    isActive
                                    ? Color.primary
                                    : Color.gray.opacity(0.2)
                                )
                                .frame(width: 12, height: 12)
                        }
                    }
                }
                .padding(.top, 20)

                Spacer()

                // Doguinho
                if let imageName = viewModel.displayedPetImageName {
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 280)
                        .opacity(displayedVisualState == .noConnection ? 0.45 : 1)
                } else {
                    // Fallback visual enquanto carrega ou se houver erro
                    Image("harry")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 280)
                        .opacity(displayedVisualState == .noConnection ? 0.45 : 1)
                }

                Text(displayedVisualState.message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.top, 8)

                // Botão principal
                Button {
                    guard let user = session.currentUser else { return }

                    Task {
                        if await viewModel.createDoguinhoRequest(for: user) {
                            // O listener persistido atualiza a Home após a
                            // confirmação da transação no Firestore.
                        }
                    }
                } label: {
                    HStack(spacing: 8) {
                        if viewModel.isSendingRequest {
                            ProgressView()
                                .tint(.white)
                        }

                        Text(viewModel.isSendingRequest ? "ENVIANDO..." : "BORA DOGUINHO?")
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(.pink)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 32)
                .disabled(
                    !displayedVisualState.isConnected
                    || session.currentUser?.connectedUserId == nil
                    || viewModel.activePetId == nil
                    || displayedVisualState == .delivering
                    || displayedVisualState == .received
                    || viewModel.isSendingRequest
                )
                .opacity(
                    (!displayedVisualState.isConnected
                    || session.currentUser?.connectedUserId == nil
                    || viewModel.activePetId == nil
                    || displayedVisualState == .delivering
                    || displayedVisualState == .received
                    || viewModel.isSendingRequest) ? 0.55 : 1
                )

                Spacer()
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )
            .padding(.top, 8)
        }
        .animation(.easeInOut(duration: 0.25), value: isShowingMenu)
        .sheet(isPresented: $isShowingRequestModal) {
            if let request = viewModel.receivedRequest,
               let user = session.currentUser {
                DoguinhoRequestModal(
                    senderName: viewModel.partnerProfile?.name ?? "Seu parceiro",
                    petImageName: viewModel.displayedPetImageName,
                    onResponse: { response in
                        try await viewModel.respond(to: request, with: response, userId: user.id)
                    },
                    onSuccess: {
                        isShowingRequestModal = false
                    }
                )
            }
        }
        .alert(
            "Não foi possível enviar",
            isPresented: Binding(
                get: { viewModel.requestErrorMessage != nil },
                set: { isPresented in
                    if !isPresented {
                        viewModel.requestErrorMessage = nil
                    }
                }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.requestErrorMessage ?? "Tente novamente.")
        }
        .onAppear {
            if let user = session.currentUser {
                Task {
                    await viewModel.loadActivePet(for: user)
                    await viewModel.loadPartner(for: user)
                    viewModel.startObservingSentRequest(for: user.id)
                    viewModel.startObservingReceivedRequest(for: user.id)
                }
            }
        }
        .onChange(of: session.currentUser) { _, newValue in
            if let user = newValue {
                Task {
                    await viewModel.loadActivePet(for: user)
                    await viewModel.loadPartner(for: user)
                    viewModel.startObservingSentRequest(for: user.id)
                    viewModel.startObservingReceivedRequest(for: user.id)
                }
            } else {
                viewModel.stopObservingSentRequest()
            }
        }
        .onChange(of: viewModel.receivedRequest?.id) { _, requestId in
            guard let requestId, !presentedRequestIds.contains(requestId) else { return }
            presentedRequestIds.insert(requestId)
            isShowingRequestModal = true
        }
        .onDisappear {
            viewModel.stopObservingSentRequest()
        }
    }

    private func avatar(initials: String, color: Color) -> some View {
        Text(initials)
            .font(.caption.bold())
            .foregroundStyle(.white)
            .frame(width: 24, height: 24)
            .background(color)
            .clipShape(Circle())
    }
}

#Preview {
    @Previewable @StateObject var session = AuthSessionStore()
    NavigationStack {
        HomeView()
    }
    .environmentObject(session)
}

#Preview("Home sem conexão") {
    @Previewable @StateObject var session = AuthSessionStore()
    NavigationStack {
        HomeView(visualState: .noConnection)
    }
    .environmentObject(session)
}

#Preview("Home pedido recebido") {
    @Previewable @StateObject var session = AuthSessionStore()
    NavigationStack {
        HomeView(visualState: .received)
    }
    .environmentObject(session)
}

#Preview("Home levando solicitação") {
    @Previewable @StateObject var session = AuthSessionStore()
    NavigationStack {
        HomeView(visualState: .delivering)
    }
    .environmentObject(session)
}

#Preview("Home retornando") {
    @Previewable @StateObject var session = AuthSessionStore()
    NavigationStack {
        HomeView(visualState: .returning)
    }
    .environmentObject(session)
}

#Preview("Home pedido expirado") {
    @Previewable @StateObject var session = AuthSessionStore()
    NavigationStack {
        HomeView(visualState: .expired)
    }
    .environmentObject(session)
}
