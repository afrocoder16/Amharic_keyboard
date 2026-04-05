import Foundation

public enum TranslationError: Error, LocalizedError {
    case noFullAccess
    case networkUnavailable
    case apiError(String)
    case invalidResponse

    public var errorDescription: String? {
        switch self {
        case .noFullAccess:
            return "Enable 'Allow Full Access' in Settings › General › Keyboard › Amharic to use translation."
        case .networkUnavailable:
            return "No internet connection. Check your network and try again."
        case .apiError(let msg):
            return "Translation service error: \(msg)"
        case .invalidResponse:
            return "Received an unexpected response from the translation service."
        }
    }
}

public protocol TranslationService {
    /// Translate `text` from `sourceLang` (e.g. "am") to `targetLang` (e.g. "en").
    func translate(text: String, from sourceLang: String, to targetLang: String) async throws -> String
}
