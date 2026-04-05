import Foundation

/// Translates text using the LibreTranslate REST API.
///
/// Configure by providing `baseURL` (default: public LibreTranslate instance) and
/// an optional `apiKey` if your instance requires authentication.
///
/// The keyboard extension must have "Allow Full Access" enabled for network calls.
public final class LibreTranslateClient: TranslationService {

    private let baseURL: URL
    private let apiKey: String?
    private let session: URLSession
    private let cache: TranslationCache

    public init(
        baseURL: URL = URL(string: "https://libretranslate.com")!,
        apiKey: String? = nil,
        cache: TranslationCache = TranslationCache()
    ) {
        self.baseURL = baseURL
        self.apiKey = apiKey
        self.cache = cache
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10
        self.session = URLSession(configuration: config)
    }

    // MARK: - TranslationService

    public func translate(text: String, from sourceLang: String, to targetLang: String) async throws -> String {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else { return "" }

        // Check cache first
        if let cached = cache.get(text: text, from: sourceLang, to: targetLang) {
            return cached
        }

        let result = try await performRequest(text: text, from: sourceLang, to: targetLang)
        cache.set(text: text, from: sourceLang, to: targetLang, result: result)
        return result
    }

    // MARK: - Private

    private func performRequest(text: String, from sourceLang: String, to targetLang: String) async throws -> String {
        let url = baseURL.appendingPathComponent("translate")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        var body: [String: String] = [
            "q": text,
            "source": sourceLang,
            "target": targetLang,
            "format": "text"
        ]
        if let key = apiKey {
            body["api_key"] = key
        }

        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw TranslationError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let msg = String(data: data, encoding: .utf8) ?? "HTTP \(httpResponse.statusCode)"
            throw TranslationError.apiError(msg)
        }

        struct TranslateResponse: Decodable {
            let translatedText: String
        }

        do {
            let decoded = try JSONDecoder().decode(TranslateResponse.self, from: data)
            return decoded.translatedText
        } catch {
            throw TranslationError.invalidResponse
        }
    }
}
