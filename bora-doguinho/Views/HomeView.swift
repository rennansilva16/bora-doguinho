import SwiftUI
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var activePetImageName: String?
    
    private let petService = PetService()
    
    func loadActivePet(for user: AppUser) async {
        do {
            let userPets = try await petService.fetchUserPets(userId: user.id)
            let catalog = try await petService.fetchCatalog()
            
            var chosenPetId = user.activePetId
            
            if user.petSelectionMode == .random, !userPets.isEmpty {
                chosenPetId = userPets.randomElement()?.id ?? "harry"
            }
            
            if let catalogItem = catalog.first(where: { $0.id == chosenPetId }) {
                self.activePetImageName = catalogItem.imageName
            }
        } catch {
            print("Erro ao carregar pet ativo: \(error.localizedDescription)")
        }
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

    init(visualState: HomeVisualState = .available) {
        _visualState = State(initialValue: visualState)
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

                    // Casal
                    HStack(spacing: 8) {
                        avatar(initials: "L", color: .pink)
                        Text("Laura")
                            .font(.headline)

                        Image(systemName: "link")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        avatar(initials: "R", color: .purple)
                        Text("Rennan")
                            .font(.headline)
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
                if let imageName = viewModel.activePetImageName {
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 280)
                        .opacity(visualState == .noConnection ? 0.45 : 1)
                } else {
                    // Fallback visual enquanto carrega ou se houver erro
                    Image("harry")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 280)
                        .opacity(visualState == .noConnection ? 0.45 : 1)
                }

                Text(visualState.message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.top, 8)

                if visualState == .received {
                    Button("Responder ao convite") {
                        isShowingRequestModal = true
                    }
                    .buttonStyle(.bordered)
                    .padding(.top, 8)
                }

                // Botão principal
                Button {
                    // Phase 1 visual-only state; Phase 5 creates the real request.
                    if visualState == .available {
                        visualState = .delivering
                    }
                } label: {
                    Text("BORA DOGUINHO?")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(.pink)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 32)
                .disabled(!visualState.isConnected || visualState == .delivering || visualState == .received)
                .opacity((!visualState.isConnected || visualState == .delivering || visualState == .received) ? 0.55 : 1)

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
            DoguinhoRequestModal { _ in
                visualState = .returning
                isShowingRequestModal = false
            }
        }
        .onAppear {
            if let user = session.currentUser {
                Task {
                    await viewModel.loadActivePet(for: user)
                }
            }
        }
        .onChange(of: session.currentUser) { _, newValue in
            if let user = newValue {
                Task {
                    await viewModel.loadActivePet(for: user)
                }
            }
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
