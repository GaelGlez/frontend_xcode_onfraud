import Foundation

// MARK: - UserProfileResponse
struct UserProfileResponse: Codable {
    let profile: Profile
}

// MARK: - Profile
struct Profile: Codable {
    let id: Int
    let fullName, email, passwordHash, salt: String
    let role: Int
    let createdAt, updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case fullName = "full_name"
        case email
        case passwordHash = "password_hash"
        case salt, role
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
