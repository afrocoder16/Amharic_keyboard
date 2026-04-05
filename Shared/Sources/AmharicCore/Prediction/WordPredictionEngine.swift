import Foundation

/// Provides Amharic word suggestions in two modes:
///   1. Mid-word completion: given a partial Ethiopic word prefix, return likely completions.
///   2. Next-word prediction: given the last committed word, return likely following words.
public final class WordPredictionEngine: ObservableObject {

    @Published public private(set) var suggestions: [String] = []

    private let store: WordFrequencyStore
    private var lastCommittedWord: String = ""

    public init(store: WordFrequencyStore = WordFrequencyStore()) {
        self.store = store
    }

    // MARK: - Public API

    /// Call this when the user is mid-word (partial Ethiopic prefix available).
    public func updateMidWord(prefix: String) {
        guard !prefix.isEmpty else {
            suggestNextWord()
            return
        }
        let completions = store.completions(for: prefix, limit: 5)
        suggestions = completions.map(\.text)
    }

    /// Call this after a word is committed (space/return pressed).
    public func wordCommitted(_ word: String) {
        lastCommittedWord = word
        suggestNextWord()
    }

    /// Clear all suggestions.
    public func clear() {
        suggestions = []
        lastCommittedWord = ""
    }

    // MARK: - Private

    private func suggestNextWord() {
        guard !lastCommittedWord.isEmpty else {
            suggestions = []
            return
        }
        let next = store.nextWords(after: lastCommittedWord, limit: 5)
        suggestions = next.map(\.text)
    }
}
