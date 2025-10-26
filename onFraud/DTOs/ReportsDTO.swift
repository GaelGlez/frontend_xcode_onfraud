import Foundation

// MARK: - Reports
struct Reports: Codable {
    let id: Int
    let user_id: Int?
    let category_id: Int
    let status_id: Int
    let title: String
    let url: String
    let description: String
    let created_at, updated_at: String
    let user_name: String?
    let category_name: String
    let status_name: String

    enum CodingKeys: String, CodingKey {
        case id
        case user_id
        case category_id
        case status_id
        case title, url, description
        case created_at
        case updated_at
        case user_name
        case category_name
        case status_name
    }
}
