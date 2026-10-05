import SwiftUI

struct ProfileView: View {
    var body: some View {
        ContentUnavailableView("Meu Perfil", systemImage: "person", description: Text("Os dados de perfil serão exibidos na Fase 9."))
    }
}

#Preview {
    ProfileView()
}
