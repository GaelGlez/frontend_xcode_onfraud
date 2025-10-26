import Foundation

struct ReportServerErrorResponse: Codable {
    let statusCode: Int
    let message: String
    let errors: [FieldError]?
    
    struct FieldError: Codable {
        let field: String
        let errors: [String]
    }
}

@MainActor
final class ReportClient: ObservableObject {
    @Published var reports: [Reports] = []
    @Published var categories: [Category] = []
    @Published var evidences: [Evidence] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let baseURL = "https://submetaphoric-lina-nonpredicative.ngrok-free.dev/reports"
    private let token: String?

    init(token: String? = nil) {
        self.token = token
    }
    
    // MARK: - Fetch Reportes
    func fetchAllReports() async {
        await fetchReports(endpoint: "\(baseURL)?status_id=2", requiresAuth: false)
    }

    func fetchAllUserReports() async {
        await fetchReports(endpoint: "\(baseURL)/user/report", requiresAuth: true)
    }

    func fetchFilterUserReports(statusId: Int) async {
        await fetchReports(endpoint: "\(baseURL)/user/report?status_id=\(statusId)", requiresAuth: true)
    }
    
    // MARK: - Fetch Categorias
    func fetchCategories() async {
        isLoading = true
        errorMessage = nil
        
        let endpoint = "\(baseURL)/categories"
        guard let url = URL(string: endpoint) else {
            errorMessage = "URL inválida"
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                throw URLError(.badServerResponse)
            }
            
            let decoded = try JSONDecoder().decode([Category].self, from: data)
            self.categories = decoded
            
        } catch {
            errorMessage = "No se pudieron cargar las categorías. \(error.localizedDescription)"
            self.categories = []
        }
        
        isLoading = false
    }
    
    // MARK: - Fetch Evidencias
    func fetchEvidences(reportId: Int) async {
        isLoading = true
        errorMessage = nil
        
        let endpoint = "\(baseURL)/\(reportId)/evidences"
        guard let url = URL(string: endpoint) else {
            errorMessage = "URL inválida"
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                throw URLError(.badServerResponse)
            }
            
            let decoded = try JSONDecoder().decode([Evidence].self, from: data)
            self.evidences = decoded
            
        } catch {
            errorMessage = "No se pudieron cargar las evidencias. \(error.localizedDescription)"
            self.evidences = []
        }
        
        isLoading = false
    }
    
    // MARK: - Funcion Fetch Reportes General
    private func fetchReports(endpoint: String, requiresAuth: Bool) async {
        isLoading = true
        errorMessage = nil

        do {
            guard let url = URL(string: endpoint) else { throw URLError(.badURL) }

            var request = URLRequest(url: url)
            request.httpMethod = "GET"

            if requiresAuth, let token = TokenStorage.get(identifier: "accessToken") {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }

            let (data, response) = try await URLSession.shared.data(for: request)

            if let http = response as? HTTPURLResponse {
                if http.statusCode == 401 {
                    let refreshed = await AuthClient.shared.refreshAccessToken()
                    if refreshed {
                        try await Task.sleep(nanoseconds: 100_000_000)
                        await fetchReports(endpoint: endpoint, requiresAuth: requiresAuth)
                        return
                    } else {
                        throw URLError(.userAuthenticationRequired)
                    }
                }
                guard (200...299).contains(http.statusCode) else {
                    throw URLError(.badServerResponse)
                }
            }

            reports = try JSONDecoder().decode([Reports].self, from: data)

        } catch {
            errorMessage = "No se pudieron cargar los reportes. \(error.localizedDescription)"
        }

        isLoading = false
    }
    
    // MARK: - Crear Reporte
    func createReport(form: PostReportFormRequest, requiresAuth: Bool = true) async -> PostReportFormResponse? {
        isLoading = true
        errorMessage = nil

        let endpoint = "\(baseURL)"
        guard let url = URL(string: endpoint) else {
            errorMessage = "URL inválida"
            isLoading = false
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        if requiresAuth, let token = TokenStorage.get(identifier: "accessToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        do {
            let bodyData = try JSONEncoder().encode(form)
            request.httpBody = bodyData

            let (data, response) = try await URLSession.shared.data(for: request)

            guard let http = response as? HTTPURLResponse else {
                throw URLError(.badServerResponse)
            }

            if http.statusCode == 401 {
                let refreshed = await AuthClient.shared.refreshAccessToken()
                if refreshed {
                    return await createReport(form: form, requiresAuth: requiresAuth)
                } else {
                    errorMessage = "Sesión expirada. Inicia sesión nuevamente."
                    return nil
                }
            }

            guard (200...299).contains(http.statusCode) else {
                if let serverError = try? JSONDecoder().decode(ReportServerErrorResponse.self, from: data) {
                    // Construimos un mensaje amigable con todos los errores
                    var fieldMessages: [String] = []
                    if let fieldErrors = serverError.errors {
                        for field in fieldErrors {
                            fieldMessages.append(contentsOf: field.errors)
                        }
                    }
                    errorMessage = fieldMessages.joined(separator: "\n")
                } else {
                    errorMessage = "Ocurrió un error interno en el servidor. Intente más tarde."
                }
                isLoading = false
                return nil
            }


            let decoded = try JSONDecoder().decode(PostReportFormResponse.self, from: data)
            isLoading = false
            return decoded

        } catch {
            errorMessage = "Error al crear el reporte: \(error.localizedDescription)"
            isLoading = false
            return nil
        }
    }
    
    // MARK: - Crear Reporte Anónimo
    func createAnonymousReport(form: PostReportFormRequest) async -> PostReportFormResponse? {
        isLoading = true
        errorMessage = nil
        
        let endpoint = "\(baseURL)/anonymous"
        guard let url = URL(string: endpoint) else {
            errorMessage = "URL inválida"
            isLoading = false
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let bodyData = try JSONEncoder().encode(form)
            request.httpBody = bodyData
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let http = response as? HTTPURLResponse else {
                throw URLError(.badServerResponse)
            }
            
            guard (200...299).contains(http.statusCode) else {
                if let serverError = try? JSONDecoder().decode(ReportServerErrorResponse.self, from: data) {
                    // Construimos un mensaje amigable con todos los errores
                    var fieldMessages: [String] = []
                    if let fieldErrors = serverError.errors {
                        for field in fieldErrors {
                            fieldMessages.append(contentsOf: field.errors)
                        }
                    }
                    errorMessage = fieldMessages.joined(separator: "\n")
                } else {
                    errorMessage = "Ocurrió un error interno en el servidor. Intente más tarde."
                }
                isLoading = false
                return nil
            }

            
            let decoded = try JSONDecoder().decode(PostReportFormResponse.self, from: data)
            isLoading = false
            return decoded
            
        } catch {
            errorMessage = "Error al crear el reporte anónimo: \(error.localizedDescription)"
            isLoading = false
            return nil
        }
    }
    
    // MARK: - Eliminar Reporte
    func deleteReport(reportId: Int) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        let endpoint = "\(baseURL)/\(reportId)"
        guard let url = URL(string: endpoint) else {
            errorMessage = "URL inválida"
            isLoading = false
            return false
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        if let token = TokenStorage.get(identifier: "accessToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            
            guard let http = response as? HTTPURLResponse else {
                throw URLError(.badServerResponse)
            }
            
            if http.statusCode == 401 {
                let refreshed = await AuthClient.shared.refreshAccessToken()
                if refreshed {
                    return await deleteReport(reportId: reportId)
                } else {
                    errorMessage = "Sesión expirada. Inicia sesión nuevamente."
                    return false
                }
            }
            
            guard (200...299).contains(http.statusCode) else {
                errorMessage = "No se pudo eliminar el reporte (Código \(http.statusCode))."
                return false
            }
            
            isLoading = false
            return true
            
        } catch {
            errorMessage = "Error al eliminar el reporte: \(error.localizedDescription)"
            isLoading = false
            return false
        }
    }
    
    // MARK: - Buscar Reportes Barra de Busqueda
    // MARK: - Buscar Reportes Barra de Busqueda
    func searchReports(keyword: String) async {
        isLoading = true
        errorMessage = nil
        
        let query = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        var urlString = "\(baseURL)?status_id=2" // 🔹 Siempre solo aprobados
        
        if !query.isEmpty {
            let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            urlString += "&q=\(encoded)"
        }
        
        guard let url = URL(string: urlString) else {
            errorMessage = "URL inválida"
            isLoading = false
            return
        }
        
        do {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            
            let (data, response) = try await URLSession.shared.data(for: request)
            if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                throw URLError(.badServerResponse)
            }
            
            reports = try JSONDecoder().decode([Reports].self, from: data)
        } catch {
            errorMessage = "No se pudieron cargar los reportes. \(error.localizedDescription)"
            reports = []
        }
        
        isLoading = false
    }
}
