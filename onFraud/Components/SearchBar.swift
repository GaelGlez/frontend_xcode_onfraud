import SwiftUI

struct SearchBar: View {
    @Binding var searchText: String
    var placeholder: String = "Busca sitio, enlace o categoría..."
    var onSearch: (() -> Void)? = nil 

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 25))
                .foregroundColor(Color("primaryGreen"))

            TextField(placeholder, text: $searchText, onCommit: {
                onSearch?()
            })
            .textFieldStyle(PlainTextFieldStyle())
            .font(.custom("Roboto-Bold", size: 16))
            .autocorrectionDisabled(true)
            .textInputAutocapitalization(.never)
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                    onSearch?()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(10)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct SearchBar_Previews: PreviewProvider {
    @State static var searchText = ""

    static var previews: some View {
        SearchBar(searchText: $searchText)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
