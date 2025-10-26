import Foundation

class ProfileClient {
    
    // MARK: - Get User Profile
    func getUserProfile(token: String) async throws -> UserProfileResponse {
        let endpoint = "https://submetaphoric-lina-nonpredicative.ngrok-free.dev/users/profile"
        guard let url = URL(string: endpoint) else {
            fatalError("Invalid URL: \(endpoint)")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        if let http = response as? HTTPURLResponse {
            if http.statusCode == 401 {
                let refreshed = await AuthClient.shared.refreshAccessToken()
                if refreshed, let newToken = TokenStorage.get(identifier: "accessToken") {
                    try await Task.sleep(nanoseconds: 100_000_000)
                    return try await getUserProfile(token: newToken)
                } else {
                    throw URLError(.userAuthenticationRequired)
                }
            }
            guard (200...299).contains(http.statusCode) else {
                throw URLError(.badServerResponse)
            }
        }

        return try JSONDecoder().decode(UserProfileResponse.self, from: data)
    }
    
    // MARK: - Update User Profile
    func updateUserProfile(token: String, fullName: String?, email: String?) async throws -> Bool {
        let endpoint = "https://submetaphoric-lina-nonpredicative.ngrok-free.dev/users"
        guard let url = URL(string: endpoint) else {
            fatalError("Invalid URL: \(endpoint)")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        // Solo enviamos los campos que no estén vacíos
        var body: [String: String] = [:]
        if let fullName = fullName, !fullName.isEmpty {
            body["full_name"] = fullName
        }
        if let email = email, !email.isEmpty {
            body["email"] = email
        }

        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])

        let (data, response) = try await URLSession.shared.data(for: request)

        if let http = response as? HTTPURLResponse {
            if http.statusCode == 401 {
                let refreshed = await AuthClient.shared.refreshAccessToken()
                if refreshed, let newToken = TokenStorage.get(identifier: "accessToken") {
                    return try await updateUserProfile(token: newToken, fullName: fullName, email: email)
                } else {
                    throw URLError(.userAuthenticationRequired)
                }
            }
            guard (200...299).contains(http.statusCode) else {
                let msg = String(data: data, encoding: .utf8) ?? "Error desconocido"
                throw NSError(domain: "ProfileClient", code: http.statusCode, userInfo: [NSLocalizedDescriptionKey: msg])
            }
        }

        return true
    }
    
    // MARK: - Update Password
    func updatePassword(token: String, oldPassword: String, newPassword: String) async throws -> Bool {
            let endpoint = "https://submetaphoric-lina-nonpredicative.ngrok-free.dev/users/password"
            guard let url = URL(string: endpoint) else { fatalError("URL inválida") }

            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

            let body: [String: String] = [
                "oldPassword": oldPassword,
                "newPassword": newPassword
            ]
            request.httpBody = try JSONSerialization.data(withJSONObject: body)

            let (_, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse else {
                throw URLError(.badServerResponse)
            }

            guard (200...299).contains(http.statusCode) else {
                throw NSError(domain: "ProfileClient", code: http.statusCode, userInfo: [NSLocalizedDescriptionKey: "Error al cambiar contraseña"])
            }

            return true
        }
}


