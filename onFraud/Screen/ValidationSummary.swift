import SwiftUI

struct ValidationSummary: View {
    var errors: [String] = []
    
    var body: some View {
        if !errors.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                // Encabezado con ícono
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(Color("primaryGreen"))
                        .font(.system(size: 22))
                    Text("Por favor revisa lo siguiente:")
                        .font(.custom("RobotoCondensed-SemiBold", size: 18))
                        .foregroundColor(.black)
                }
                
                // Lista de errores
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(errors, id: \.self) { error in
                        HStack(alignment: .top, spacing: 6) {
                            Circle()
                                .fill(Color("primaryGreen"))
                                .frame(width: 6, height: 6)
                                .padding(.top, 6)
                            Text(error)
                                .font(.custom("Roboto-Regular", size: 16))
                                .foregroundColor(.black)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .padding(.top, 4)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(red: 0.95, green: 0.98, blue: 0.95))
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
            )
            .padding(.horizontal)
            .transition(.opacity.combined(with: .move(edge: .top)))
            .animation(.easeInOut(duration: 0.3), value: errors)
        }
    }
}

#Preview {
    ValidationSummary(errors: [
        "El nombre es requerido.",
        "El correo no es válido.",
        "Debes aceptar las políticas de privacidad."
    ])
}
