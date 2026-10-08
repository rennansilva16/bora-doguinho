import Foundation
import Combine
import FirebaseAuth

@MainActor
final class AuthSessionStore: ObservableObject {
    @Published private(set) var currentUser: AppUser?
    @Published private(set) var isLoading = true
    @Published private(set) var setupError: String?
    @Published var errorMessage: String?

    private let userService = UserService()
    private var authListener: AuthStateDidChangeListenerHandle?
    private var hasStarted = false
    private var isPerformingAuthentication = false

    init() {
        setupError = FirebaseBootstrap.configureIfPossible()
        guard setupError == nil else {
            isLoading = false
            return
        }
    }

    /// Starts observing Firebase only after SwiftUI has installed this object
    /// in the environment. Firebase may invoke this listener immediately.
    func start() {
        guard !hasStarted, setupError == nil else { return }
        hasStarted = true
        authListener = Auth.auth().addStateDidChangeListener { [weak self] _, firebaseUser in
            Task { @MainActor in
                await self?.handle(firebaseUser)
            }
        }
    }

    deinit {
        if let authListener { Auth.auth().removeStateDidChangeListener(authListener) }
    }

    func signUp(name: String, email: String, password: String) async -> Bool {
        var firebaseUser: FirebaseAuth.User?
        isPerformingAuthentication = true
        defer { isPerformingAuthentication = false }

        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        do {
            let result = try await Auth.auth().createUser(withEmail: normalizedEmail, password: password)
            firebaseUser = result.user
            let profile = try await userService.createProfile(
                id: result.user.uid,
                name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                email: normalizedEmail
            )
            currentUser = profile
            isLoading = false
            return true
        } catch {
            // Authentication and Firestore cannot share one transaction. If the
            // profile batch fails, remove the just-created account so a retry
            // does not leave an unusable sign-in without a profile document.
            if let firebaseUser {
                try? await firebaseUser.delete()
            }
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }

    func signIn(email: String, password: String) async -> Bool {
        isPerformingAuthentication = true
        defer { isPerformingAuthentication = false }

        do {
            let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            let result = try await Auth.auth().signIn(withEmail: normalizedEmail, password: password)
            currentUser = try await userService.fetchProfile(id: result.user.uid)
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }

    func sendPasswordReset(to email: String) async -> Bool {
        do {
            let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            try await Auth.auth().sendPasswordReset(withEmail: normalizedEmail)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
    
    func updatePetSelection(activePetId: String, mode: PetSelectionMode) {
        guard var user = currentUser else { return }

        user.activePetId = activePetId
        user.petSelectionMode = mode
        currentUser = user
    }

    /// Atualiza o connectedUserId localmente após operação bem-sucedida no Firestore.
    /// Chame este método após aceitar um convite, após o sender detectar a conexão via listener,
    /// ou após desconectar — para manter a UI em sincronia sem re-fetch do perfil completo.
    func updateConnection(connectedUserId: String?) {
        guard var user = currentUser else { return }
        user.connectedUserId = connectedUserId
        currentUser = user
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            currentUser = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func handle(_ firebaseUser: FirebaseAuth.User?) async {
        guard !isPerformingAuthentication else { return }
        defer { isLoading = false }
        guard let firebaseUser else {
            currentUser = nil
            return
        }

        do {
            currentUser = try await userService.fetchProfile(id: firebaseUser.uid)
        } catch {
            currentUser = nil
            errorMessage = error.localizedDescription
        }
    }
}
