import SwiftUI

struct CustomHeader: View {
    var title: String
    var showBackButton: Bool = false
    var showProfileIcon: Bool = true
    var onBack: (() -> Void)? = nil
    var onProfileTap: (() -> Void)? = nil
    var titleFontSize: CGFloat = 32
    var horizontalPadding: CGFloat = 15
    var headerHeight: CGFloat = 120
    var spaceBetweenTitleAndContent: CGFloat = 10
    var isTitleCentered: Bool = false
    var customContent: AnyView? = nil
    
    private let backButtonWidth: CGFloat = 40
    
    var body: some View {
        VStack {
            ZStack {
                Text(title)
                    .font(.custom("RobotoCondensed-SemiBold", size: titleFontSize))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: isTitleCentered ? .center : .leading)
                    .padding(.leading, (!isTitleCentered && showBackButton) ? backButtonWidth + 5 : 0)
                
                HStack {
                    if showBackButton {
                        Button(action: { onBack?() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    } 
                    
                    Spacer()
                    
                    if showProfileIcon {
                        Button(action: { onProfileTap?() }) {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 45))
                                .foregroundColor(.white)
                        }
                    } else {
                        Color.clear.frame(width: 45, height: 45)
                    }
                }
            }
            .padding(.horizontal, horizontalPadding)
            
            if let customContent = customContent {
                Spacer().frame(height: spaceBetweenTitleAndContent)
                customContent
                    .padding(.horizontal, horizontalPadding)
            }            
        }
        .frame(maxWidth: .infinity)
        .frame(height: headerHeight)
        .background(Color("primaryGreen"))
    }
}

#Preview {
    @State var selectedFilter = "Todas"
    
    VStack(spacing: 25) {
        CustomHeader(
            title: "onFraud",
            showProfileIcon: true,
            titleFontSize: 48,
            headerHeight: 160,
            spaceBetweenTitleAndContent: 25,
            customContent: AnyView(
                HStack {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 25))
                        .foregroundColor(Color("primaryGreen"))
                    TextField("Busca sitio, enlace o categoría...", text: .constant(""))
                        .textFieldStyle(PlainTextFieldStyle())
                        .font(.custom("Roboto-Bold", size: 16))
                }
                .padding(10)
                .background(Color.white)
                .cornerRadius(15)
            ),
        )
        
        Divider()
        
        CustomHeader(
            title: "Mis Reportes",
            headerHeight: 160,
            spaceBetweenTitleAndContent: 40,
            customContent: AnyView(
                ReportFilterBar(selectedFilter: $selectedFilter)
            )
        )
        
        Divider()
        
        CustomHeader(
            title: "Detalle de Reporte",
            showBackButton: true,
            showProfileIcon: true,
            headerHeight: 90,
        )
        
    }
    .previewLayout(.sizeThatFits)
    .background(Color.gray.opacity(0.1))
}
