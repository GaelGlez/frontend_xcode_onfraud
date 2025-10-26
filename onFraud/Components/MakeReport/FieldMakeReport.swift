import SwiftUI

struct FieldMakeReport: View {
    var label: String
    var mandatory: Bool = false
    var customContent: AnyView? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack{
                Text(label)
                    .font(.custom("Roboto-Bold", size: 16))
                    .foregroundColor(Color(.primaryGreen))
                    
                
                if mandatory {
                    Text("*")
                        .font(.custom("Roboto-Bold", size: 16))
                        .foregroundColor(Color(.primaryGreen))
                }
                
            }
            if let customContent = customContent {
                customContent
            }
        }
    }
}

#Preview {
    VStack(spacing: 25){
        FieldMakeReport(
            label: "Titulo",
            mandatory: true,
            customContent: AnyView(
                TextInputFieldReport(
                    placeholder: "Aqui va el titulo",
                    text: .constant(""),
                    type: .singleLine
                )
            )
        )
        
        FieldMakeReport(
            label: "Descripción",
            mandatory: true,
            customContent: AnyView(
                TextInputFieldReport(
                    placeholder: "Descripción (varias líneas)",
                    text: .constant(""),
                    type: .multiLine
                )
            )
        )
        
        
    }
    .padding()
}
