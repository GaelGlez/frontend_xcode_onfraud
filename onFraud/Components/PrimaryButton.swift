import SwiftUI

enum ButtonStyleType {
    case solid
    case outline
}

struct PrimaryButton: View {
    var title: String
    var style: ButtonStyleType = .solid
    var customColor: String = "primaryGreen"
    
    var body: some View {
            Text(title)
                .font(.custom("Roboto-Bold", size: 20))
                .foregroundColor(style == .solid ? .white : Color(customColor))
                //.frame(maxWidth: .infinity)
                .frame(maxWidth: 317)
                .frame(height: 44)
                .background(style == .solid ? Color(customColor) : Color.clear)
                .cornerRadius(10)
                .overlay(
                    style == .outline ?
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(customColor), lineWidth: 2)
                    : nil
                )
        }
    }

#Preview {
    VStack(spacing: 20) {
        PrimaryButton(title: "Iniciar sesión ", style: .solid)
        
        PrimaryButton(title: "Registrarse", style: .outline)
        PrimaryButton(title: "Registrarse", style: .outline, customColor: "primaryRed")
    }
}
