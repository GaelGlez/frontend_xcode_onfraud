import SwiftUI

struct PrivacyPolicySheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Encabezado
                    Text("Políticas de Privacidad")
                        .font(.custom("Roboto-Bold", size: 28))
                        .foregroundColor(Color("primaryGreen"))
                        .padding(.bottom, 4)
                    
                    Divider()
                        .background(Color("primaryGreen"))
                    
                    // Contenido
                    Text("""
                    En onFraud nos tomamos muy en serio la privacidad de tus datos. Toda la información que compartes con nosotros se almacena de manera segura y se utiliza únicamente para mejorar tu experiencia dentro de la aplicación.

                    Tus datos no serán vendidos ni compartidos con terceros sin tu consentimiento explícito. Puedes solicitar en cualquier momento la eliminación de tu información personal.

                    Te recomendamos leer cuidadosamente estas políticas para entender cómo manejamos tus datos y tus derechos como usuario.
                    """)
                    .font(.custom("Roboto-Regular", size: 17))
                    .foregroundColor(.primary)
                    .lineSpacing(6)
                    .multilineTextAlignment(.leading)
                }
                .padding(24)
            }
            
            // Botón de cerrar
            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(Color("primaryGreen"))
            }
            .padding(24)
        }
    }
}

#Preview {
    PrivacyPolicySheet()
}
