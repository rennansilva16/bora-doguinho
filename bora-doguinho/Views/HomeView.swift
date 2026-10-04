import SwiftUI

struct HomeView: View {
    @State private var isShowingMenu = false

    var body: some View {
        HStack(spacing: 0) {

            // Side menu
            if isShowingMenu {
                SideMenuView(isShowing: $isShowingMenu)
                    .frame(width: 240)
                    .shadow(radius: 4)
            }

            // Home
            VStack(spacing: 0) {

                // Header
                HStack {
                    // Menu
                    Button {
                        isShowingMenu.toggle()
                    } label: {
                        Image(systemName: "line.3.horizontal")
                            .font(.title2)
                            .frame(width: 44, height: 44)
                    }

                    Spacer()

                    // Casal
                    HStack(spacing: 8) {
                        Text("Laura")
                            .font(.headline)

                        Image(systemName: "lock.fill")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Text("Rennan")
                            .font(.headline)
                    }

                    Spacer()

                    // Espaço para manter o casal realmente centralizado
                    Color.clear
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal, 8)

                // Indicador semanal
                HStack(spacing: 12) {
                    ForEach(
                        Array(zip(
                            ["D", "S", "T", "Q", "Q", "S", "S"],
                            [true, true, false, false, true, false, false]
                        )),
                        id: \.0
                    ) { day, isActive in
                        VStack(spacing: 6) {
                            Text(day)
                                .font(.caption)
                                .fontWeight(.medium)

                            Circle()
                                .fill(
                                    isActive
                                    ? Color.primary
                                    : Color.gray.opacity(0.2)
                                )
                                .frame(width: 12, height: 12)
                        }
                    }
                }
                .padding(.top, 20)

                Spacer()

                // Doguinho
                Image("harry")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 280)

                // Botão principal
                Button {
                    // Ação será implementada na Fase 5.
                } label: {
                    Text("BORA DOGUINHO?")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(.pink)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 32)

                Spacer()
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )
            .padding(.top, 8)
        }
        .animation(.easeInOut(duration: 0.25), value: isShowingMenu)
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
}
