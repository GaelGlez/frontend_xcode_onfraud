import Foundation

enum APIError: LocalizedError {
    case serverError(statusCode: Int, message: String)
    case decodingError
    case unknownError
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .serverError(_, let message):
            return message
        case .decodingError:
            return "Error al procesar la respuesta del servidor."
        case .unknownError:
            return "Ocurrió un error desconocido."
        case .invalidResponse:
            return "La respuesta del servidor no es válida."
        }
    }
}
