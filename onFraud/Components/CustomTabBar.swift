import SwiftUI

enum Tab {
    case home
    case report
    case myReports
}

struct CustomTabBarView: View {
    @Binding var selectedTab: Tab

    var body: some View {
        HStack(spacing: 40)  {
            // 🏠 Inicio
            tabButton(tab: .home, icon: "house.fill", text: "Inicio", height: 68)

            //Spacer(minLength: 48)

            // ➕ Hacer reporte
            Button {
                selectedTab = .report
            } label: {
                VStack(spacing: 6) {
                    Image("makeReportIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 104.67, height: 91)
                }
            }
            .frame(maxWidth: .infinity)
            .foregroundColor(.white)

            tabButton(tab: .myReports, icon: "doc.text.magnifyingglass", text: "Mis Reportes", height: 68)
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 20)
        .background(Color("primaryGreen"))
        .shadow(radius: 3)
    }

    // MARK: - Reusable Button
    @ViewBuilder
    private func tabButton(tab: Tab, icon: String, text: String, height: CGFloat) -> some View {
        Button {
            selectedTab = tab
        } label: {
            ZStack(alignment: .bottom) {
                VStack(spacing: 6) {
                    Image(systemName: icon)
                        .font(.system(size: 30))
                    Text(text)
                        .font(.custom("RobotoCondensed-Medium", size: 15))
                }
                .frame(width: 80, height: height)
                .foregroundColor(.white)

                if selectedTab == tab {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.white)
                        .frame(width: 80 ,height: 4)
                        .offset(y: 3)
                }
            }
            
        }
    }
}

#Preview {
    PreviewWrapper()
}

struct PreviewWrapper: View {
    @State private var selectedTab: Tab = .home

    var body: some View {
        VStack(spacing: 20) {
            CustomTabBarView(selectedTab: $selectedTab)
        }
        .previewLayout(.sizeThatFits)
        .background(Color.gray.opacity(0.2))
    }
}

