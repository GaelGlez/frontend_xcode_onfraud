import Foundation

struct PostReportFormRequest: Codable {
    let title: String
    let category_id: Int
    let url: String
    let description: String
    let evidences: [String]
}

struct PostReportFormResponse: Codable {
    let id, categoryID, statusID: Int
    let userID: Int?
    let title: String
    let url: String
    let description, createdAt, updatedAt: String
    let userName: String?
    let categoryName, statusName: String

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case categoryID = "category_id"
        case statusID = "status_id"
        case title, url, description
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case userName = "user_name"
        case categoryName = "category_name"
        case statusName = "status_name"
    }
}

