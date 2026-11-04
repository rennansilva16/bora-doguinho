import SwiftUI

struct DoguinhoRequestModal: View {
    let senderName: String
    let petImageName: String?
    let onResponse: (DoguinhoRequestStatus) async throws -> Void
    let onSuccess: () -> Void

    @State private var isSubmitting = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 24) {
            Image(petImageName ?? "harry")
                .resizable()
                .scaledToFit()
                .frame(height: 180)

            VStack(spacing: 8) {
                Text("BORA DOGUINHO?")
                    .font(.title.bold())
                Text("\(senderName) enviou um convite pelo doguinho.")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 12) {
                responseButton("❤️ Sim!", color: .pink, response: .accepted)
                responseButton("⏰ Daqui a 15 minutos", color: .orange, response: .delayed)
                responseButton("❌ Agora não posso", color: .gray, response: .declined)
            }
        }
        .padding(32)
        .presentationDetents([.medium])
        .interactiveDismissDisabled()
        .alert("Não foi possível responder", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "Tente novamente.")
        }
    }

    private func responseButton(
        _ title: String,
        color: Color,
        response: DoguinhoRequestStatus
    ) -> some View {
        Button {
            Task {
                isSubmitting = true
                defer { isSubmitting = false }

                do {
                    try await onResponse(response)
                    onSuccess()
                } catch {
                    errorMessage = error.localizedDescription
                }
            }
        } label: {
            HStack {
                if isSubmitting { ProgressView().tint(.white) }
                Text(title)
            }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .foregroundStyle(.white)
                .background(color)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .disabled(isSubmitting)
    }
}
