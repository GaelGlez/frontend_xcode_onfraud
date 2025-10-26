import Foundation

@MainActor
final class AuthClient: ObservableObject {
    static let shared = AuthClient()

    @Published var accessToken: String? = TokenStorage.get(identifier: "accessToken")
    @Published var refreshToken: String? = TokenStorage.get(identifier: "refreshToken")
    @Published var isLoggedIn: Bool = TokenStorage.get(identifier: "accessToken") != nil

    private let baseURL = "https://submetaphoric-lina-nonpredicative.ngrok-free.dev/auth"

    private init() {}

    // MARK: - Refresh token
    func refreshAccessToken() async -> Bool {
        guard let refreshToken = TokenStorage.get(identifier: "refreshToken"),
              let url = URL(string: "\(baseURL)/refresh-token") else {
            logout()
            return false
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["token": refreshToken])

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
                logout()
                return false
            }

            let decoded = try JSONDecoder().decode(TokenResponse.self, from: data)
            TokenStorage.set(identifier: "accessToken", value: decoded.accessToken)
            accessToken = decoded.accessToken
            return true
        } catch {
            logout()
            return false
        }
    }

    // MARK: - Logout
    func logout() {
        TokenStorage.delete(identifier: "accessToken")
        TokenStorage.delete(identifier: "refreshToken")
        accessToken = nil
        refreshToken = nil
        isLoggedIn = false
        NotificationCenter.default.post(name: .didLogout, object: nil)
    }
    
    // MARK: - Delete account
    func deleteAccount() async -> Bool {
        guard var token = accessToken,
              let url = URL(string: "\(baseURL)/delete-account") else {
            logout()
            return false
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            if let http = response as? HTTPURLResponse, http.statusCode == 401 {
                // Token expirado, intentar refrescar
                let refreshed = await refreshAccessToken()
                if refreshed, let newToken = accessToken {
                    token = newToken
                    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                    let (_, secondResponse) = try await URLSession.shared.data(for: request)
                    if let secondHttp = secondResponse as? HTTPURLResponse,
                       (200...299).contains(secondHttp.statusCode) {
                        return true
                    } else {
                        return false
                    }
                } else {
                    logout()
                    return false
                }
            }
            
            guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
                return false
            }
            
            return true
        } catch {
            print("Error al eliminar la cuenta:", error)
            return false
        }
    }
}

// MARK: - Model para el response
struct TokenResponse: Codable {
    let accessToken: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
}

// MARK: - Notification Name
extension Notification.Name {
    static let didLogout = Notification.Name("didLogout")
}
