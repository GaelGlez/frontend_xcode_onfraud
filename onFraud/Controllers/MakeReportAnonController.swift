import SwiftUI

@MainActor
final class MakeReportAnonController: ObservableObject {
    @Published var titleText = ""
    @Published var selectedCategory = ""
    @Published var urlText = ""
    @Published var descriptionText = ""
    @Published var showSuccess = false
    @Published var showError = false
    @Published var successMessage = ""
    @Published var errorMessage = ""
    @Published var isSubmitting = false
    @Published var categoriesErrorMessage: String? = nil
    @Published var isLoadingCategories = false
    
    let reportClient = ReportClient()
    @Published var evidenceVM = EvidencePickerController()
    
    // MARK: - Cargar categorías
    func loadCategories() async {
        isLoadingCategories = true
        defer { isLoadingCategories = false } // asegura que siempre termine en false
        do {
            try await reportClient.fetchCategories()
            categoriesErrorMessage = nil
            if selectedCategory.isEmpty, let first = reportClient.categories.first {
                selectedCategory = first.name
            }
        } catch {
            categoriesErrorMessage = "No se pudieron cargar las categorías."
        }
    }

    
    // MARK: - Enviar reporte anónimo
    func sendReport() async {
        // Validación local primero
        let errores = validarCampos()
        if !errores.isEmpty {
            errorMessage = errores.joined(separator: "\n")
            showError = true
            return
        }

        guard let categoryId = reportClient.categories.first(where: { $0.name == selectedCategory })?.id else {
            errorMessage = "Categoría no válida."
            showError = true
            return
        }

        // Esperar a que todas las imágenes terminen de subir
        while evidenceVM.isUploading {
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1s
        }

        let form = PostReportFormRequest(
            title: titleText,
            category_id: categoryId,
            url: urlText,
            description: descriptionText,
            evidences: evidenceVM.evidences
        )

        isSubmitting = true
        if let response = await reportClient.createAnonymousReport(form: form) {
            successMessage = "Reporte anónimo creado con éxito: \(response.title)"
            showSuccess = true
        } else {
            showError = true
            errorMessage = reportClient.errorMessage ?? "Ocurrió un error al crear el reporte."
        }
        isSubmitting = false
    }

    
    func validarCampos() -> [String] {
        var errores: [String] = []

        if titleText.esVacio {
            errores.append("El título es obligatorio.")
        } else if !titleText.esTituloValido {
            errores.append("El título debe tener entre 5 y 100 caracteres y solo puede contener letras y espacios.")
        }

        if urlText.esVacio {
            errores.append("La URL es obligatoria.")
        } else if !urlText.esUrlValida {
            errores.append("La URL no es válida o supera el máximo permitido (2083 caracteres).")
        }

        if descriptionText.esVacio {
            errores.append("La descripción es obligatoria.")
        } else if !descriptionText.esDescripcionValida {
            errores.append("La descripción debe tener entre 20 y 1000 caracteres y solo puede contener letras y espacios.")
        }

        if selectedCategory.isEmpty {
            errores.append("Selecciona una categoría antes de continuar.")
        }

        return errores
    }
}
