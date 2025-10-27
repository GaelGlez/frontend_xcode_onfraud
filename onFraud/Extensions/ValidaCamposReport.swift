import Foundation

extension String {
    // Título: 5 a 100 caracteres
    var esTituloValido: Bool {
        let regex = #"^[A-Za-zÁÉÍÓÚáéíóúÑñ0-9.,!¡¿?()\-:;'"\s]{5,100}$"#
        return self.range(of: regex, options: .regularExpression) != nil
    }

    // URL: válida la url con el estandar de apple
    var esUrlValida: Bool {
        guard let url = URL(string: self) else { return false }
        return ["http", "https"].contains(url.scheme)
    }

    // Descripción: 20 a 1000 caracteres
    var esDescripcionValida: Bool {
        self.count >= 20 && self.count <= 1000
    }
}


