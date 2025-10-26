import SwiftUI

struct ReportCardView: View {
    var titulo: String
    var categoria: String
    var url: String? = nil
    var descripcion: String
    var status: ReportStatus? = nil
    var fechaCreacion: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            VStack(alignment: .leading, spacing: 2) {
                Text(titulo)
                    .font(.custom("Roboto-Bold", size: 18))
                    .foregroundColor(Color("primaryGreen"))
                    .lineLimit(2)
                
                if let fechaCreacion = fechaCreacion {
                    Text(formattedDate(from: fechaCreacion))
                        .font(.custom("Roboto-Medium", size: 15))
                        .foregroundColor(.black)
                }
                
                HStack{
                Text("Categoría:")
                    .font(.custom("Roboto-SemiBold", size: 15))
                    .foregroundColor(.black)
                    
                    Text("\(categoria)")
                        .font(.custom("Roboto-Regular", size: 15))
                        .foregroundColor(.black)
                }
                
                HStack{
                    if let url = url {
                        Text("URL:")
                            .font(.custom("Roboto-SemiBold", size: 15))
                            .foregroundColor(.black)
                            .lineLimit(1)
                        
                        Text("\(url)")
                            .font(.custom("Roboto-Regular", size: 15))
                            .foregroundColor(.blue)
                            .underline()
                            .lineLimit(1)
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 20){
                Text(descripcion)
                    .font(.body)
                    .foregroundColor(.black)
                    .lineLimit(3)
                
                if let status = status {
                    // 🟢 Estado
                    Text(status.displayName)
                        .font(.custom("Roboto-SemiBold", size: 20))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(status.color)
                        .cornerRadius(14)
                        .padding(.top, 6)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.25), radius: 10, x: 0, y: 0)
    }

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

// MARK: - Enum para representar el estado del reporte
enum ReportStatus {
    case pendiente // pendiente
    case aprobado // aprobado
    case rechazado // rechazado

    var displayName: String {
        switch self {
        case .pendiente: return "Pendiente"
        case .aprobado: return "Aprobado"
        case .rechazado: return "Rechazado"
        }
    }

    var color: Color {
        switch self {
        case .pendiente: return .primaryYellow
        case .aprobado: return .primaryGreen
        case .rechazado: return .primaryRed
        }
    }
    
    init(from name: String) {
        switch name.lowercased() {
        case "pendiente": self = .pendiente
        case "aprobado": self = .aprobado
        case "rechazado": self = .rechazado
        default: self = .pendiente
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        ReportCardView(
            titulo: "Paquete Cancún All-Inclusive por $999",
            categoria: "Hoteles",
            url: "www.viajesflash-cancun.com",
            descripcion: "Promoción sospechosa en redes. Pedían depósito sin comprobante oficial que se hace las cosas muy extralas hasta el punto en que."
        )

        ReportCardView(
            titulo: "Compra falsa de celular",
            categoria: "Electrónicos",
            //url: "www.fakecellstore.com",
            descripcion: "Promoción sospechosa en redes. Pedían depósito sin comprobante oficial que se hace las cosas muy extralas hasta el punto en que.",
            status: .rechazado,
            fechaCreacion: "2025-10-03T21:07:59.000Z"
        )
    }
    .padding()
    .background(Color(.systemGray6))
}
