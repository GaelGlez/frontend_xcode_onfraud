import SwiftUI

struct AddEvidenceButton: View {
    var title: String
    var systemImage: String
    var action: (() -> Void)? = nil
    
    var body: some View {
        Button(action: {
            action?()
        }) {
            HStack(spacing: 10) {
                Image(systemName: systemImage)
                    .font(.title) 
                Text(title)
                    .font(.custom("Roboto-SemiBold", size: 17))
            }
            .foregroundColor(Color("primaryGreen"))
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(Color("backgroundFields"))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color("primaryGreen"), lineWidth: 3)
            )
            .cornerRadius(10)
        }
    }
}

#Preview {
    VStack(spacing: 15) {
        AddEvidenceButton(title: "Tomar Foto", systemImage: "camera.fill")
        AddEvidenceButton(title: "Subir desde Galería", systemImage: "photo.fill")
    }
}
