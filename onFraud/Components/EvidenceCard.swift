import SwiftUI

struct EvidenceCard: View {
    var nombreEvidencia: String
    var onTap: (() -> Void)? = nil  
    var customContent: AnyView? = nil
    
    var body: some View {
        HStack(spacing: 12) {
            Image("evidenceIcon")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .cornerRadius(8)
                .background(Color.gray.opacity(0.2))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(nombreEvidencia)
                    .font(.custom("Roboto-Medium", size: 16))
                    .foregroundColor(Color("primaryGreen"))
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                Text("Toca para ver")
                    .font(.custom("Roboto-Regular", size: 14))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            if let customContent = customContent {
                customContent
            }

        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .onTapGesture {
            onTap?()
        }
    }
}

#Preview {
    VStack(spacing: 10) {
        EvidenceCard(
            nombreEvidencia: "onFraud_First_Frame.png",
            customContent: AnyView(
                Image(systemName: "chevron.right")
                    .foregroundColor(Color(.primaryGreen))
            )
        )
        
        EvidenceCard(
            nombreEvidencia: "prueba_filtros_botones_First_Frame.png",
            customContent: AnyView(
                Image(systemName: "xmark")
                    .foregroundColor(Color(.primaryGreen))
            )
        )
    }
    .padding()
    .background(Color.gray.opacity(0.1))
}
