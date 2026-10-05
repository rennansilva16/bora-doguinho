import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var session: AuthSessionStore

    var body: some View {
        Group {
            if session.isLoading {
                ProgressView("Carregando…")
            } else if let setupError = session.setupError {
                FirebaseSetupRequiredView(message: setupError)
            } else if session.currentUser == nil {
                AuthFlowView()
            } else {
                mainTabs
            }
        }
        .task {
            session.start()
        }
    }

    private var mainTabs: some View {
        TabView {
            NavigationStack {
                HomeView()
            }
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            PetsView()
                .tabItem {
                    Label("Pets", systemImage: "pawprint.fill")
                }

            ClothesView()
                .tabItem {
                    Label("Roupas", systemImage: "tshirt.fill")
                }

            ShopView()
                .tabItem {
                    Label("Loja", systemImage: "bag.fill")
                }
        }
    }
}

#Preview {
    @Previewable @StateObject var session = AuthSessionStore()
    ContentView()
        .environmentObject(session)
}
