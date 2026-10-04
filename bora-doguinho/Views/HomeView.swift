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

            // Home content
            VStack {
                Button {
                    isShowingMenu.toggle()
                } label: {
                    Image(systemName: "line.3.horizontal")
                        .font(.title2)
                        .frame(width: 44, height: 44)
                }

                Spacer()
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .topLeading
            )
            .padding(.top, 8)
            .padding(.leading, 8)
        }
        .animation(.easeInOut(duration: 0.25), value: isShowingMenu)
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
    
}
