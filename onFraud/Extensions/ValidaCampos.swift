extension String {
    var esVacio: Bool {
        return self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var esCorreoValido: Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,255}"
        return self.range(of: regex, options: .regularExpression) != nil
    }

    var esNombreValido: Bool {
        let regex = "^[A-Za-zÁÉÍÓÚáéíóúÑñ ]{5,100}$"
        return self.range(of: regex, options: .regularExpression) != nil
    }

    var esPasswordLongitudValida: Bool {
        return self.count >= 9 && self.count <= 64
    }

    var esPasswordCompleja: Bool {
        let regex = "^(?=.*[A-Z])(?=.*\\d).+$"
        return self.range(of: regex, options: .regularExpression) != nil
    }
}
