import Foundation

enum FlashcardError: Error, LocalizedError {
    case invalidRequest
    case networkError
    case parsingError
    case unauthorized
    case rateLimited
    case serverError
    case modelNotFound
    
    var errorDescription: String? {
        switch self {
        case .invalidRequest:
            return "Invalid request format"
        case .networkError:
            return "Network connection error"
        case .parsingError:
            return "Failed to parse AI response"
        case .unauthorized:
            return "Invalid API key. Please check your API key."
        case .rateLimited:
            return "Rate limit exceeded. Please try again later."
        case .serverError:
            return "Server error. Please try again."
        case .modelNotFound:
            return "Model not found. Please check the API configuration."
        }
    }
} 