import SwiftUI

struct ShopView: View {
    var body: some View {
        ContentUnavailableView {
            Label("A lojinha está chegando!", systemImage: "bag")
        } description: {
            Text("Ainda não há compras, moedas ou inventário no MVP.")
        }
    }
}

#Preview {
    ShopView()
}
