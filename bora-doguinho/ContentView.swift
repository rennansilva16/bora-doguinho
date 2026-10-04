import SwiftUI

struct ContentView: View {
    var body: some View {
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
    ContentView()
}
