import SwiftUI

struct TextInputFieldReport: View {
    enum FieldType {
        case singleLine
        case multiLine
    }

    var placeholder: String
    @Binding var text: String
    var type: FieldType = .singleLine

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            switch type {
            case .singleLine:
                TextField("", text: $text)
                    .placeholder(when: text.isEmpty) {
                        Text(placeholder)
                            .foregroundColor(.gray)
                            .font(.custom("Roboto-Regular", size: 15))
                    }
                    .font(.custom("Roboto-Regular", size: 15))
                    .foregroundColor(.black)
                    .frame(height: 40)
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.never)
                
            case .multiLine:
                ZStack(alignment: .topLeading) {
                    if text.isEmpty {
                        Text(placeholder)
                            .foregroundColor(.gray)
                            .font(.custom("Roboto-Regular", size: 15))
                            .padding(.top, 8)
                    }
                    TextEditor(text: $text)
                        .font(.custom("Roboto-Regular", size: 15))
                        .foregroundColor(.black)
                        .frame(height: 165)
                        .scrollContentBackground(.hidden)
                        .padding(.leading, -4)
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color("backgroundFields"))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color("primaryGreen"), lineWidth: 3)
        )
        .cornerRadius(10)
    }
}

// MARK: - Extensión para TextField placeholder
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            if shouldShow { placeholder() }
            self
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        TextInputFieldReport(
            placeholder: "Nombre (una línea)",
            text: .constant(""),
            type: .singleLine
        )
        
        TextInputFieldReport(
            placeholder: "Descripción (varias líneas)",
            text: .constant(""),
            type: .multiLine
        )
    }
    .padding()
    .background(Color(.systemGray6))
}
