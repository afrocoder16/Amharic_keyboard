import Foundation

/// Translates text using the Google Cloud Translation API v2 (Basic).
///
/// Setup:
///   1. Go to https://console.cloud.google.com
///   2. Enable "Cloud Translation API" on your project
///   3. Create an API key under APIs & Services → Credentials
///   4. Paste the key into GoogleTranslateConfig.apiKey below
///      OR store it in UserDefaults(suiteName: appGroupID) under key "google_translate_api_key"
///      so you can update it from the container app without rebuilding.
public final class GoogleTranslateClient: TranslationService {

    private static let endpoint = "https://translation.googleapis.com/language/translate/v2"

    private let apiKey: String
    private let session: URLSession
    private let cache: TranslationCache

    /// - Parameter apiKey: Your Google Cloud Translation API key.
    ///   Defaults to `GoogleTranslateConfig.apiKey` which reads from UserDefaults or the
    ///   hardcoded fallback below.
    public init(
        apiKey: String = GoogleTranslateConfig.apiKey,
        cache: TranslationCache = TranslationCache()
    ) {
        self.apiKey = apiKey
        self.cache = cache
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10
        self.session = URLSession(configuration: config)
    }

    // MARK: - TranslationService

    public func translate(text: String, from sourceLang: String, to targetLang: String) async throws -> String {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return "" }

        if let cached = cache.get(text: trimmed, from: sourceLang, to: targetLang) {
            return cached
        }

        let result = try await performRequest(text: trimmed, from: sourceLang, to: targetLang)
        cache.set(text: trimmed, from: sourceLang, to: targetLang, result: result)
        return result
    }

    // MARK: - Private

    private func performRequest(text: String, from sourceLang: String, to targetLang: String) async throws -> String {
        guard var components = URLComponents(string: Self.endpoint) else {
            throw TranslationError.invalidResponse
        }
        components.queryItems = [URLQueryItem(name: "key", value: apiKey)]

        guard let url = components.url else { throw TranslationError.invalidResponse }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = GoogleTranslateRequest(q: text, source: sourceLang, target: targetLang, format: "text")
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await session.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw TranslationError.invalidResponse
        }

        guard http.statusCode == 200 else {
            // Parse Google's error format
            if let errResp = try? JSONDecoder().decode(GoogleErrorResponse.self, from: data) {
                throw TranslationError.apiError(errResp.error.message)
            }
            throw TranslationError.apiError("HTTP \(http.statusCode)")
        }

        let decoded = try JSONDecoder().decode(GoogleTranslateResponse.self, from: data)
        guard let translation = decoded.data.translations.first?.translatedText else {
            throw TranslationError.invalidResponse
        }

        // Google HTML-encodes certain characters — decode them
        return translation
            .replacingOccurrences(of: "&#39;", with: "'")
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
    }
}

// MARK: - Configuration

/// Store your Google Translate API key here or in UserDefaults (App Group).
public enum GoogleTranslateConfig {
    /// The App Group UserDefaults key for the API key (set from the container app).
    static let userDefaultsKey = "google_translate_api_key"
    static let appGroupID = "group.com.amharickeyboard"

    /// Returns the API key: checks UserDefaults first, then falls back to the hardcoded value.
    /// To set at runtime from the container app:
    ///   UserDefaults(suiteName: appGroupID)?.set("YOUR_KEY", forKey: userDefaultsKey)
    public static var apiKey: String {
        if let stored = UserDefaults(suiteName: appGroupID)?.string(forKey: userDefaultsKey),
           !stored.isEmpty {
            return stored
        }
        // ← PASTE YOUR GOOGLE CLOUD TRANSLATION API KEY HERE
        return "YOUR_GOOGLE_TRANSLATE_API_KEY"
    }
}

// MARK: - Codable Models

private struct GoogleTranslateRequest: Encodable {
    let q: String
    let source: String
    let target: String
    let format: String
}

private struct GoogleTranslateResponse: Decodable {
    let data: TranslationsData

    struct TranslationsData: Decodable {
        let translations: [Translation]
    }

    struct Translation: Decodable {
        let translatedText: String
    }
}

private struct GoogleErrorResponse: Decodable {
    let error: ErrorBody

    struct ErrorBody: Decodable {
        let message: String
        let code: Int
    }
}
