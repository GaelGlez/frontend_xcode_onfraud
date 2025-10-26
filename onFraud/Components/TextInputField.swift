import SwiftUI

struct TextInputField: View {
    var label: String
    var placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    
    @State private var showText: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(label)
                .font(.custom("Roboto-Bold", size: 12))
                .foregroundColor(.black)
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.never)


            
            HStack {
                if isSecure && !showText {
                    SecureField(placeholder, text: $text)
                        .font(.custom("Roboto-Medium", size: 16))
                        .foregroundColor(.black)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)

                } else {
                    TextField(placeholder, text: $text)
                        .font(.custom("Roboto-Medium", size: 16))
                        .foregroundColor(.black)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                }
                
                if isSecure {
                    Spacer(minLength: 8)
                    Button(action: { showText.toggle() }) {
                        Image(systemName: showText ? "eye.slash" : "eye")
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .padding()
        .frame(height: 60)
        .background(Color("backgroundFields"))
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color("primaryGreen"), lineWidth: 3)
        )
        .cornerRadius(15)
    }
}


#Preview {
    VStack(spacing: 20) {
        TextInputField(
            label: "Usuario",
            placeholder: "Ingresa tu usuario",
            text: .constant("")
        )

        TextInputField(
            label: "Contraseña",
            placeholder: "••••••••",
            text: .constant("password123"),
            isSecure: true
        )
    }
    .padding()
    .background(Color(.systemGray6))
}





