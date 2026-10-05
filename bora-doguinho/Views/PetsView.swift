import SwiftUI

struct PetsView: View {
    var body: some View {
        ContentUnavailableView("Pets", systemImage: "pawprint.fill", description: Text("A seleção de Harry, Pandora e Aleatório será conectada ao Firestore na Fase 3."))
    }
}

#Preview {
    PetsView()
}
