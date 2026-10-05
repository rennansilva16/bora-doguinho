import SwiftUI

struct FirebaseSetupRequiredView: View {
    let message: String

    var body: some View {
        ContentUnavailableView {
            Label("Firebase precisa ser configurado", systemImage: "exclamationmark.triangle")
        } description: {
            Text(message)
        }
        .padding()
    }
}
