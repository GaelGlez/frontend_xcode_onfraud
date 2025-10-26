import Foundation

extension String {
    // Título: 5 a 100 caracteres
    var esTituloValido: Bool {
        let regex = #"^[A-Za-zÁÉÍÓÚáéíóúÑñ0-9.,!¡¿?()\-:;'"\s]{5,100}$"#
        return self.range(of: regex, options: .regularExpression) != nil
    }

    // URL: válida y máximo 2083 caracteres
    var esUrlValida: Bool {
        guard self.count <= 2083 else { return false }
        let pattern = #"^(https?:\/\/)?([\w\-]+\.)+[\w\-]+(\/[\w\-._~:/?#[\]@!$&'()*+,;=%]*)?$"#
        return self.range(of: pattern, options: .regularExpression) != nil
    }


    // Descripción: 20 a 1000 caracteres
    var esDescripcionValida: Bool {
        self.count >= 20 && self.count <= 1000
    }
}


