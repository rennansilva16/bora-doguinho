import SwiftUI

/// Visual-only request modal used to complete the Phase 1 prototype.
/// Phase 5 replaces the callbacks with Firestore-backed request handling.
struct DoguinhoRequestModal: View {
    enum Response {
        case accepted
        case delayed
        case declined
    }

    let onResponse: (Response) -> Void

    var body: some View {
        VStack(spacing: 24) {
            Image("harry")
                .resizable()
                .scaledToFit()
                .frame(height: 180)

            VStack(spacing: 8) {
                Text("BORA DOGUINHO?")
                    .font(.title.bold())
                Text("O doguinho trouxe um convite para você.")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 12) {
                responseButton("❤️ Sim!", color: .pink) {
                    onResponse(.accepted)
                }
                responseButton("⏰ Daqui a 15 minutos", color: .orange) {
                    onResponse(.delayed)
                }
                responseButton("❌ Agora não posso", color: .gray) {
                    onResponse(.declined)
                }
            }
        }
        .padding(32)
        .presentationDetents([.medium])
        .interactiveDismissDisabled()
    }

    private func responseButton(_ title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .foregroundStyle(.white)
                .background(color)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
}
