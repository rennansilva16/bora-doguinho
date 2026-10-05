import SwiftUI

struct ClothesView: View {
    var body: some View {
        ContentUnavailableView {
            Label("Roupinhas em breve!", systemImage: "tshirt")
        } description: {
            Text("Em breve os doguinhos poderão usar novos looks.")
        }
    }
}

#Preview {
    ClothesView()
}
