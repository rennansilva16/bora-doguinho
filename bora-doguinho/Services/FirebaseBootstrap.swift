import Foundation
import FirebaseCore

enum FirebaseBootstrap {
    static func configureIfPossible() -> String? {
        guard FirebaseApp.app() == nil else { return nil }

        guard Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil else {
            return "Adicione o arquivo GoogleService-Info.plist do projeto Firebase ao target Bora Doguinho para habilitar a autenticação."
        }

        FirebaseApp.configure()
        return nil
    }
}
