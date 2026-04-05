import Foundation

/// Loads and indexes the Amharic word frequency list for fast prefix lookups.
/// The word list file format (amharic_wordlist.txt) is one entry per line:
///   word<TAB>frequency
/// e.g.:  ነው	45230
public final class WordFrequencyStore {

    // MARK: - Trie node for O(prefix_len) lookup

    private final class TrieNode {
        var children: [Character: TrieNode] = [:]
        var word: String?
        var frequency: Int = 0
    }

    private let root = TrieNode()

    // MARK: - Bigram table
    // bigrams["ነው"] = [("አሁን", 120), ("ይሆናል", 85), ...]
    public private(set) var bigrams: [String: [(word: String, count: Int)]] = [:]

    // MARK: - Init

    public init() {
        loadWordList()
        loadBigrams()
    }

    // MARK: - Public API

    /// Returns up to `limit` words that start with `prefix`, sorted by frequency desc.
    public func completions(for prefix: String, limit: Int = 5) -> [AmharicWord] {
        guard !prefix.isEmpty else { return [] }
        var node = root
        for char in prefix {
            guard let next = node.children[char] else { return [] }
            node = next
        }
        var results: [AmharicWord] = []
        collectWords(from: node, prefix: prefix, into: &results)
        return Array(results.sorted { $0.frequency > $1.frequency }.prefix(limit))
    }

    /// Returns up to `limit` likely next words after `word` using bigram frequency.
    public func nextWords(after word: String, limit: Int = 5) -> [AmharicWord] {
        guard let candidates = bigrams[word] else { return [] }
        return candidates
            .sorted { $0.count > $1.count }
            .prefix(limit)
            .map { AmharicWord(text: $0.word, frequency: $0.count) }
    }

    // MARK: - Private

    private func insert(word: String, frequency: Int) {
        var node = root
        for char in word {
            if node.children[char] == nil {
                node.children[char] = TrieNode()
            }
            node = node.children[char]!
        }
        node.word = word
        node.frequency = frequency
    }

    private func collectWords(from node: TrieNode, prefix: String, into results: inout [AmharicWord]) {
        if let word = node.word {
            results.append(AmharicWord(text: word, frequency: node.frequency))
        }
        for (char, child) in node.children {
            collectWords(from: child, prefix: prefix + String(char), into: &results)
        }
    }

    private func loadWordList() {
        guard let url = Bundle.module.url(forResource: "amharic_wordlist", withExtension: "txt"),
              let content = try? String(contentsOf: url, encoding: .utf8) else {
            loadBuiltInWords()
            return
        }
        for line in content.components(separatedBy: "\n") {
            let parts = line.components(separatedBy: "\t")
            guard parts.count >= 1, !parts[0].isEmpty else { continue }
            let word = parts[0].trimmingCharacters(in: .whitespaces)
            let freq = parts.count >= 2 ? Int(parts[1]) ?? 1 : 1
            insert(word: word, frequency: freq)
        }
    }

    private func loadBigrams() {
        guard let url = Bundle.module.url(forResource: "amharic_bigrams", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let json = try? JSONDecoder().decode([String: [String: Int]].self, from: data) else {
            return
        }
        for (word, nextWords) in json {
            bigrams[word] = nextWords.map { (word: $0.key, count: $0.value) }
        }
    }

    /// Fallback: a small set of the most common Amharic words hardcoded.
    private func loadBuiltInWords() {
        let common: [(String, Int)] = [
            ("ነው", 45000), ("አለ", 38000), ("ይሆናል", 29000), ("ነበር", 27000),
            ("አሁን", 25000), ("ይሆን", 22000), ("ሆነ", 21000), ("ሆነ", 20000),
            ("ስለ", 19000), ("እና", 18000), ("ወይም", 17000), ("ለ", 16000),
            ("ምን", 15000), ("ማን", 14000), ("የት", 13000), ("እንዴ", 12000),
            ("ሰላም", 11000), ("አዎ", 10000), ("አይ", 9500), ("ደህና", 9000),
            ("ምስጋና", 8500), ("ጥሩ", 8000), ("መልካም", 7500), ("አመሰግናለሁ", 7000),
            ("ይቅርታ", 6500), ("እባክህ", 6000), ("ውሃ", 5500), ("ምግብ", 5000),
            ("ቤት", 4500), ("ሰው", 4000), ("ልጅ", 3500), ("ሚስት", 3000),
            ("ሚስት", 2800), ("ቀን", 2600), ("ሌሊት", 2400), ("ጠዋት", 2200),
        ]
        for (word, freq) in common {
            insert(word: word, frequency: freq)
        }
    }
}
