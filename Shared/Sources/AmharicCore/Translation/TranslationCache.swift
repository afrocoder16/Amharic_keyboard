import Foundation

/// Simple LRU translation cache backed by UserDefaults (shared App Group).
public final class TranslationCache {

    private let maxEntries = 200
    private let suiteName: String
    private let cacheKey = "amharic_translation_cache"
    private let orderKey = "amharic_translation_cache_order"

    public init(appGroupID: String = "group.com.amharickeyboard") {
        self.suiteName = appGroupID
    }

    // MARK: - Public API

    public func get(text: String, from: String, to: String) -> String? {
        let key = cacheKey(text: text, from: from, to: to)
        return dict[key]
    }

    public func set(text: String, from: String, to: String, result: String) {
        let key = cacheKey(text: text, from: from, to: to)
        var d = dict
        var order = accessOrder

        if d[key] == nil {
            order.append(key)
            if order.count > maxEntries {
                let evict = order.removeFirst()
                d.removeValue(forKey: evict)
            }
        }
        d[key] = result

        let defaults = UserDefaults(suiteName: suiteName)
        defaults?.set(d, forKey: cacheKey)
        defaults?.set(order, forKey: orderKey)
    }

    // MARK: - Private

    private var dict: [String: String] {
        UserDefaults(suiteName: suiteName)?.dictionary(forKey: cacheKey) as? [String: String] ?? [:]
    }

    private var accessOrder: [String] {
        UserDefaults(suiteName: suiteName)?.stringArray(forKey: orderKey) ?? []
    }

    private func cacheKey(text: String, from: String, to: String) -> String {
        "\(from):\(to):\(text)"
    }
}
