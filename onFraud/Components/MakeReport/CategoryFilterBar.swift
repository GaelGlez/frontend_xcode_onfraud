import SwiftUI

struct CategoryFilterBar: View {
    let categories: [String]
    @Binding var selectedCategory: String

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(categories, id: \.self) { category in
                    FilterButtonView(
                        title: category,
                        isSelected: selectedCategory == category
                    )
                    .onTapGesture {
                        selectedCategory = category
                    }
                }
            }
            .padding(.horizontal, 1)
            .padding(.vertical, 8)
        }
        //.frame(height: 50)
    }
}

struct FilterButtonView: View {
    var title: String
    var isSelected: Bool = false
    
    var body: some View {
        Text(title)
            .font(.custom(isSelected ? "RobotoCondensed-Bold" : "RobotoCondensed-Medium", size: 15))
            .foregroundColor(isSelected ? Color("primaryGreen") : Color.gray)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? Color(.backgroundFields) : Color(.backgroundFields).opacity(0.5))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color(.primaryGreen) : Color.gray.opacity(0.5), lineWidth: 1.5)
            )
    }
}

struct CategoryFilterBarView_Previews: PreviewProvider {
    @State static var selected = "Hoteles"
    
    static var previews: some View {
        CategoryFilterBar(
            categories: ["Hoteles", "Electrónicos", "Ropa", "Viajes", "Deportes", "Alimentos"],
            selectedCategory: $selected
        )
    }
}
