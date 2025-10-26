import Foundation
import SwiftUI
import PhotosUI

@MainActor
final class EvidencePickerController: ObservableObject {
    // MARK: - Bindings separados
    @Published var cameraImage: UIImage? = nil
    @Published var galleryImage: UIImage? = nil
    @Published var photoPickerItem: PhotosPickerItem? = nil
    @Published var showCamera: Bool = false

    // MARK: - Estado de subida
    @Published var isUploading: Bool = false
    @Published var uploadStatusMessage: String? = nil
    @Published var evidences: [String] = []

    private let client = EvidenceClient()
    private var uploadingSet = Set<String>()

    // Base URL para descargar imágenes
    private let baseURL = "https://submetaphoric-lina-nonpredicative.ngrok-free.dev/public/uploads/"

    // MARK: - Subida automática (cámara o galería)
    func uploadAutomatically(_ image: UIImage) async {
        let tmp = uniqueTemporaryKey(for: image)
        guard !uploadingSet.contains(tmp) else { return }

        uploadingSet.insert(tmp)
        isUploading = true
        uploadStatusMessage = "Subiendo imagen..."

        do {
            let response = try await client.uploadImage(image)
            evidences.append(response.fileKey)
            uploadStatusMessage = "Imagen subida ✅"
        } catch {
            uploadStatusMessage = "Error al subir: \(error.localizedDescription)"
        }

        isUploading = false
        uploadingSet.remove(tmp)
    }

    // MARK: - Generar clave temporal para evitar duplicados
    private func uniqueTemporaryKey(for image: UIImage) -> String {
        "tmp_\(image.size.width)x\(image.size.height)_\(Int(Date().timeIntervalSince1970))"
    }

    // MARK: - Manejo de cámara
    func handleCameraImage(_ image: UIImage) async {
        cameraImage = image
        await uploadAutomatically(image)
        cameraImage = nil
    }

    // MARK: - Manejo de PhotosPicker
    func pickPhoto(_ item: PhotosPickerItem?) {
        Task {
            if let data = try? await item?.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                galleryImage = uiImage
                await uploadAutomatically(uiImage)
                galleryImage = nil // limpiamos para evitar doble subida
            }
        }
    }

    // MARK: - Eliminar evidencia
    func deleteEvidence(_ fileKey: String) {
        Task {
            do {
                try await client.deleteFile(named: fileKey)
                if let idx = evidences.firstIndex(of: fileKey) {
                    evidences.remove(at: idx)
                }
                uploadStatusMessage = "Evidencia eliminada"
            } catch {
                uploadStatusMessage = "Error al eliminar: \(error.localizedDescription)"
            }
        }
    }

    // MARK: - Obtener UIImage desde fileKey
    func getUIImage(for fileKey: String) async -> UIImage? {
        guard let url = URL(string: "\(baseURL)\(fileKey)") else { return nil }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return UIImage(data: data)
        } catch {
            print("Error al descargar imagen \(fileKey): \(error)")
            return nil
        }
    }
}
