import SwiftUI

struct ReportFilterBar: View {
    @Binding var selectedFilter: String
    
    private let filtros = ["Todos", "Pendientes", "Aprobados", "Rechazados"]
    
    var body: some View {
            HStack(spacing: 15) { 
                ForEach(filtros, id: \.self) { estado in
                    Button(action: {
                        selectedFilter = estado
                    }) {
                        Text(estado)
                            .font(.custom(
                                selectedFilter == estado
                                ? "RobotoCondensed-Bold"
                                : "RobotoCondensed-Medium",
                                size: 15
                            ))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 10)
                            .background(
                                selectedFilter == estado ? Color.white : Color.clear
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.white, lineWidth: selectedFilter == estado ? 10 : 2)
                            )
                            .foregroundColor(
                                selectedFilter == estado
                                ? Color("primaryGreen")
                                : .white
                            )
                    }
                }

            }
            .frame(maxWidth: .infinity)
        }
    }

#Preview {
    @State var selectedFilter = "Todos"
    
    ReportFilterBar(selectedFilter: $selectedFilter)
    
    .background(Color.gray)

}
