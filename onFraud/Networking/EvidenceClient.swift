import Foundation
import UIKit

struct UploadResponse: Codable {
    let fileKey: String
    let url: String
}

@MainActor
final class EvidenceClient {
    private let uploadURLString = "https://submetaphoric-lina-nonpredicative.ngrok-free.dev/files/upload"
    private let deleteURLString = "https://submetaphoric-lina-nonpredicative.ngrok-free.dev/files/delete"

    init() {}

    // MARK: - Upload Imagfe
    func uploadImage(_ image: UIImage, fileName: String? = nil, compression: CGFloat = 0.8) async throws -> UploadResponse {
        guard let url = URL(string: uploadURLString) else {
            throw URLError(.badURL)
        }
        guard let imageData = image.jpegData(compressionQuality: compression) else {
            throw NSError(domain: "EvidenceClient", code: -1, userInfo: [NSLocalizedDescriptionKey: "No se pudo convertir la imagen a JPEG"])
        }

        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        // filename seguro (si el backend espera el nombre original, ajusta)
        let safeFileName: String
        if let fileName = fileName, !fileName.isEmpty {
            safeFileName = fileName.replacingOccurrences(of: " ", with: "_")
        } else {
            safeFileName = "photo_\(Int(Date().timeIntervalSince1970)).jpg"
        }

        var body = Data()
        // Campo `file` coincidente con tu interceptor @UseInterceptors(FileInterceptor('file', ...))
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(safeFileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        // Usamos URLSession.upload (async) para enviar el body
        let (data, response) = try await URLSession.shared.upload(for: request, from: body)

        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard (200...299).contains(http.statusCode) else {
            // intentamos leer message body para mejor error
            let msg = String(data: data, encoding: .utf8) ?? "HTTP \(http.statusCode)"
            throw NSError(domain: "EvidenceClient", code: http.statusCode, userInfo: [NSLocalizedDescriptionKey: msg])
        }

        let decoded = try JSONDecoder().decode(UploadResponse.self, from: data)
        return decoded
    }

    // MARK: - Delete File
    func deleteFile(named fileKey: String) async throws {
        guard let url = URL(string: deleteURLString) else { throw URLError(.badURL) }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["filename": fileKey]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (_, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw URLError(.badServerResponse) }
        guard (200...299).contains(http.statusCode) else {
            throw NSError(domain: "EvidenceClient", code: http.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP \(http.statusCode)"])
        }
    }
}
