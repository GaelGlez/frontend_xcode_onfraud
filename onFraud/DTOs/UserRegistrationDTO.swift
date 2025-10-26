import Foundation

struct RegistrationFormRequest:Codable {
    var full_name: String
    var email: String
    var password: String
}

struct RegistrationFormResponse: Decodable {
        let id: Int?
        let email, full_name, passwordHash, salt: String

        enum CodingKeys: String, CodingKey {
            case id, email, full_name
            case passwordHash = "password_hash"
            case salt
        }
    }
