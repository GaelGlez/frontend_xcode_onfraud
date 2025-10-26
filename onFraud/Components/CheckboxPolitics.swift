import SwiftUI

struct CheckboxPolitics: View {
    @Binding var aceptaPoliticas: Bool
    @Binding var mostrarPoliticas: Bool
    
    var body: some View {
        HStack(alignment: .top) {
            Button { aceptaPoliticas.toggle() } label: {
                Image(systemName: aceptaPoliticas ? "checkmark.square.fill" : "square")
                    .font(.system(size: 24))
                    .foregroundColor(Color("primaryGreen"))
            }

            Button { mostrarPoliticas.toggle() } label: {
                Text("Acepto las políticas de privacidad")
                    .font(.custom("RobotoCondensed-Regular", size: 18))
                    .foregroundColor(Color("primaryGreen"))
                    .underline()
            }
            Spacer()
        }
    }
}

// MARK: - Preview
struct CheckboxPolitics_Previews: PreviewProvider {
    @State static var acepta = false
    @State static var mostrar = false
    
    static var previews: some View {
        CheckboxPolitics(
            aceptaPoliticas: $acepta,
            mostrarPoliticas: $mostrar
        )
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
