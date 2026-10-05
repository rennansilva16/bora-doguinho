import SwiftUI

struct SettingsView: View {
    var body: some View {
        ContentUnavailableView("Configurações", systemImage: "gearshape", description: Text("As configurações do perfil serão concluídas na Fase 9."))
    }
}

#Preview {
    SettingsView()
}
