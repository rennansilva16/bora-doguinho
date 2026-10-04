import SwiftUI

struct SideMenuView: View {
    @Binding var isShowing: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            Text("Menu")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.bottom, 12)

            NavigationLink {
                ProfileView()
            } label: {
                Label("Meu Perfil", systemImage: "person.fill")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            NavigationLink {
                SettingsView()
            } label: {
                Label("Configurações", systemImage: "gearshape.fill")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            NavigationLink {
                ConnectionView()
            } label: {
                Label("Conexão", systemImage: "link")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            NavigationLink {
                NotificationsView()
            } label: {
                Label("Notificações", systemImage: "bell.fill")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Spacer()

            Button {
                // Logout será implementado posteriormente.
            } label: {
                Label(
                    "Sair",
                    systemImage: "rectangle.portrait.and.arrow.right"
                )
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .font(.body)
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .topLeading
        )
        .background(.background)
        .overlay(alignment: .trailing) {
            Divider()
        }
    }
}

#Preview {
    SideMenuView(isShowing: .constant(true))
        .frame(width: 240)
}
