import Foundation

struct HTTPClient {
    
    struct ServerErrorResponse: Codable {
        let message: String
        let statusCode: Int?
    }
    
    func UserRegistration(name: String, email: String, password: String) async throws -> RegistrationFormResponse {
        let requestForm = RegistrationFormRequest(full_name: name, email: email, password: password)
        let url = URL(string: "https://submetaphoric-lina-nonpredicative.ngrok-free.dev/auth/register")!
        var httpRequest = URLRequest(url: url)
        httpRequest.httpMethod = "POST"
        httpRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        httpRequest.httpBody = try JSONEncoder().encode(requestForm)

        let (data, response) = try await URLSession.shared.data(for: httpRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        // Si el servidor regresa error (como 400, 409, etc.)
        if !(200...299).contains(httpResponse.statusCode) {
            // Intentamos decodificar el mensaje de error que manda el backend
            if let serverError = try? JSONDecoder().decode(ServerErrorResponse.self, from: data) {
                throw APIError.serverError(statusCode: httpResponse.statusCode, message: serverError.message)
            } else {
                throw APIError.serverError(statusCode: httpResponse.statusCode, message: "Ocurrió un error interno en el servidor. Intente más tarde.")
            }
        }

        do {
            let response = try JSONDecoder().decode(RegistrationFormResponse.self, from: data)
            return response
        } catch {
            throw APIError.decodingError
        }
    }

    
    func UserLogin(email: String, password: String) async throws -> LoginResponse {
        let loginRequest = LoginRequest(email: email, password: password)
        guard let url = URL(string: "https://submetaphoric-lina-nonpredicative.ngrok-free.dev/auth/login") else {
            fatalError("Invalid URL")
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try? JSONEncoder().encode(loginRequest)

        let (data, response) = try await URLSession.shared.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        if !(200...299).contains(httpResponse.statusCode) {
            if let serverError = try? JSONDecoder().decode(HTTPClient.ServerErrorResponse.self, from: data) {
                throw APIError.serverError(statusCode: httpResponse.statusCode, message: serverError.message)
            } else {
                throw APIError.serverError(statusCode: httpResponse.statusCode, message: "Ocurrió un error interno en el servidor. Intente más tarde.")
            }
        }

        do {
            let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
            return loginResponse
        } catch {
            throw APIError.decodingError
        }
    }

}
