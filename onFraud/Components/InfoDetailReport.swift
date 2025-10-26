import SwiftUI

struct InfoDetailReport: View {
    var status: ReportStatus
    var titulo: String
    var fechaCreacion: String
    var categoria: String
    var url: String
    var id: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10){
            Text(status.displayName)
                .font(.custom("Roboto-SemiBold", size: 20))
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(status.color)
                .cornerRadius(14)
                .padding(.top, 6)
            
            VStack(alignment: .leading, spacing: 15){
                Text(titulo)
                    .font(.custom("Roboto-Bold", size: 20))
                    .foregroundColor(Color("primaryGreen"))
                
                VStack(alignment: .leading, spacing: 5){
                    Text(formattedDate(from: fechaCreacion))
                        .font(.custom("Roboto-Regular", size: 16))
                        .foregroundColor(.black)
                    
                    HStack{
                        Text("ID:")
                            .font(.custom("Roboto-SemiBold", size: 16))
                            .foregroundColor(.black)
                        
                        Text("\(id)")
                            .font(.custom("Roboto-Regular", size: 16))
                            .foregroundColor(.black)
                    }
                    
                    HStack{
                        Text("Categoría:")
                            .font(.custom("Roboto-SemiBold", size: 16))
                            .foregroundColor(.black)
                        
                        Text("\(categoria)")
                            .font(.custom("Roboto-Regular", size: 16))
                            .foregroundColor(.black)
                    }
                    
                    HStack(alignment: .top) {
                        Text("URL:")
                            .font(.custom("Roboto-SemiBold", size: 16))
                            .foregroundColor(.black)
                    
                        Text("\(url)")
                            .font(.custom("Roboto-Regular", size: 16))
                            .foregroundColor(.blue)
                            .underline()
                        
                    }
                }
            }
        }
    }
    // Función para formatear fecha "2025-10-03T21:07:59.000Z" → "3 de octubre del 2025"
    private func formattedDate(from dateString: String) -> String {
        let inputFormatter = ISO8601DateFormatter()
        inputFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        if let date = inputFormatter.date(from: dateString) {
            let outputFormatter = DateFormatter()
            outputFormatter.locale = Locale(identifier: "es_MX")
            outputFormatter.timeZone = TimeZone.current
            outputFormatter.dateFormat = "d 'de' MMMM 'del' yyyy"
            return outputFormatter.string(from: date)
        } else {
            return dateString
        }
    }
}

#Preview {
    InfoDetailReport(
        status: .rechazado,
        titulo: "Compra falsa de celular",
        fechaCreacion: "2025-10-03T21:07:59.000Z",
        categoria: "Electrónicos",
        url: "www.fakecellstore.com/productos/examen/apostole",
        id: 1
    )
}
