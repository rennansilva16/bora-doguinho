import SwiftUI
import Combine

@MainActor
final class PetsViewModel: ObservableObject {
    @Published var availablePets: [PetCatalogItem] = []
    @Published var isLoading = true
    @Published var errorMessage: String?
    
    private let petService = PetService()
    
    func loadPets(for userId: String) async {
        isLoading = true
        errorMessage = nil
        do {
            let userPets = try await petService.fetchUserPets(userId: userId)
            let catalog = try await petService.fetchCatalog()
            
            // Join user pets with catalog to get image URLs
            let userPetIds = Set(userPets.map { $0.id })
            self.availablePets = catalog.filter { userPetIds.contains($0.id) }
                .sorted { $0.name < $1.name } // order alphabetically
        } catch {
            self.errorMessage = "Erro ao carregar pets: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    func selectPet(userId: String, petId: String, mode: PetSelectionMode) async -> Bool {
        do {
            try await petService.updatePetSelection(userId: userId, activePetId: petId, mode: mode)
            return true
        } catch {
            self.errorMessage = "Erro ao salvar seleção: \(error.localizedDescription)"
            return false
        }
    }
}

struct PetsView: View {
    @EnvironmentObject var session: AuthSessionStore
    @StateObject private var viewModel = PetsViewModel()
    
    // We use a local state to visually update immediately while saving
    @State private var localActivePetId: String = ""
    @State private var localSelectionMode: PetSelectionMode = .specific
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Carregando seus doguinhos...")
                } else if let error = viewModel.errorMessage {
                    ContentUnavailableView("Erro", systemImage: "exclamationmark.triangle", description: Text(error))
                } else {
                    List {
                        Section("Seus Doguinhos") {
                            ForEach(viewModel.availablePets) { pet in
                                petRow(pet: pet)
                            }
                        }
                        
                        Section("Modo Especial") {
                            randomRow()
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Pets")
            .onAppear {
                if let user = session.currentUser {
                    localActivePetId = user.activePetId
                    localSelectionMode = user.petSelectionMode
                    Task {
                        await viewModel.loadPets(for: user.id)
                    }
                }
            }
            .onChange(of: session.currentUser?.activePetId) { _, newValue in
                if let newValue { localActivePetId = newValue }
            }
            .onChange(of: session.currentUser?.petSelectionMode) { _, newValue in
                if let newValue { localSelectionMode = newValue }
            }
        }
    }
    
    private func petRow(pet: PetCatalogItem) -> some View {
        let isSelected = (localSelectionMode == .specific && localActivePetId == pet.id)
        
        return Button {
            select(petId: pet.id, mode: .specific)
        } label: {
            HStack(spacing: 16) {
                Image(pet.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1))
                
                Text(pet.name)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.pink)
                        .font(.title3)
                }
            }
            .padding(.vertical, 4)
        }
    }
    
    private func randomRow() -> some View {
        let isSelected = (localSelectionMode == .random)
        
        return Button {
            select(petId: localActivePetId, mode: .random)
        } label: {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.purple.opacity(0.1))
                        .frame(width: 50, height: 50)
                    Image(systemName: "dice.fill")
                        .font(.title2)
                        .foregroundStyle(.purple)
                }
                
                VStack(alignment: .leading) {
                    Text("Aleatório")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text("Um doguinho surpresa a cada envio")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.pink)
                        .font(.title3)
                }
            }
            .padding(.vertical, 4)
        }
    }
    
    private func select(petId: String, mode: PetSelectionMode) {
        guard let user = session.currentUser else { return }
        
        // Optimistic UI update
        localActivePetId = petId
        localSelectionMode = mode
        
        Task {
            let success = await viewModel.selectPet(userId: user.id, petId: petId, mode: mode)
            if success {
                session.updatePetSelection(
                    activePetId: petId,
                    mode: mode
                )
            } else {
                // Revert on failure
                localActivePetId = user.activePetId
                localSelectionMode = user.petSelectionMode
            }
        }
    }
}

#Preview {
    PetsView()
        .environmentObject(AuthSessionStore())
}
