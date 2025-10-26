import SwiftUI

struct SubmitButton: View {
    var isDisabled: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            PrimaryButton(title: "Enviar Reporte", style: .solid)
        }
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.6 : 1)
    }
}

