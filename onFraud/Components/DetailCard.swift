import SwiftUI

struct DetailCard: View {
    var titulo: String
    var descripcion: String?
    var customContent: AnyView? = nil 
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15){
            VStack(alignment: .leading, spacing: 10){
                Text(titulo)
                    .font(.custom("Roboto-Bold", size: 18))
                    .foregroundColor(Color(.primaryGreen))
                
                if let descripcion = descripcion {
                    Text("\(descripcion)")
                        .font(.custom("Roboto-Regular", size: 16))
                        .foregroundColor(.black)
                }
                
                if let customContent = customContent {
                    customContent
                }
                
                
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.25), radius: 10, x: 0, y: 0)
    }
}

#Preview {
    VStack{
        DetailCard(
            titulo: "Descripcion",
            descripcion: "El anuncio, publicado en varias páginas de Facebook y grupos de viajes, ofrecía un paquete de dos noches en Cancún “todo incluido” por solo $999 pesos por persona. El texto promocional incluía fotografías de hoteles de lujo y afirmaba que la oferta era válida únicamente “por tiempo limitado”."
        )
        
        DetailCard(
            titulo: "Evidencia",
            customContent: AnyView(
                EvidenceCard(nombreEvidencia: "Whatsapp.png")
            )
        )
    }
    .padding()
    .background(Color(.systemGray6))
}
