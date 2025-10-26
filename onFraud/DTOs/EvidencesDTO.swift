import Foundation

// MARK: - Evidence
struct Evidence: Codable {
    let id, reportsID: Int
    let fileKey, filePath, fileType, uploadedAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case reportsID = "reports_id"
        case fileKey = "file_key"
        case filePath = "file_path"
        case fileType = "file_type"
        case uploadedAt = "uploaded_at"
    }
}

struct ImageItem: Identifiable {
    let id = UUID()
    let url: String
}
