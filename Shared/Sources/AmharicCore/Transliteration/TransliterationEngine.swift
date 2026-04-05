import Foundation

/// Converts a stream of Latin keystrokes into Ethiopic (Amharic) characters using
/// greedy longest-match transliteration.
///
/// Usage:
///   1. Call `process(key:)` for every Latin character the user types.
///   2. Observe `markedText` for the uncommitted in-progress syllable (show underlined).
///   3. Observe `committedText` for fully resolved Ethiopic characters (insert into document).
///   4. Call `flush()` when the user presses space/punctuation/return to commit the buffer.
///   5. Call `reset()` to clear everything (e.g. when the text field changes).
public final class TransliterationEngine: ObservableObject {

    // MARK: - Published State

    /// In-progress Latin characters not yet resolved to an Ethiopic character.
    /// Show this as marked/underlined text in the document.
    @Published public private(set) var markedText: String = ""

    /// Newly committed Ethiopic text ready to be inserted into the document.
    /// Consume this value immediately after observing, then set to "".
    @Published public private(set) var committedText: String = ""

    // MARK: - Private State

    private var buffer: String = ""
    private let sortedKeys = EthiopicCharacterMap.sortedKeys
    private let map = EthiopicCharacterMap.map

    public init() {}

    // MARK: - Public API

    /// Feed a single Latin character (or backspace sentinel) into the engine.
    /// - Parameter key: A single character string. Pass "\u{08}" for backspace.
    public func process(key: String) {
        if key == "\u{08}" || key == "\u{7F}" {
            handleBackspace()
            return
        }

        buffer += key
        resolveBuffer()
    }

    /// Flush any remaining buffer content as-is (e.g. when space is pressed).
    /// Returns the flushed string so the caller can insert it.
    @discardableResult
    public func flush() -> String {
        let pending = buffer
        buffer = ""
        markedText = ""
        if !pending.isEmpty {
            committedText = pending
        }
        return pending
    }

    /// Reset all internal state (call when switching text fields).
    public func reset() {
        buffer = ""
        markedText = ""
        committedText = ""
    }

    // MARK: - Private

    private func handleBackspace() {
        if !buffer.isEmpty {
            buffer.removeLast()
            markedText = buffer
        } else {
            // Signal backspace to the host document
            committedText = "\u{08}"
        }
    }

    private func resolveBuffer() {
        var result = ""
        var remaining = buffer

        while !remaining.isEmpty {
            if let match = findLongestMatch(in: remaining) {
                result.append(match.ethiopic)
                remaining = String(remaining.dropFirst(match.latin.count))
            } else if couldMatchPrefix(remaining) {
                // The remaining prefix could still become a longer match — keep in buffer
                break
            } else {
                // No match and no possible future match — emit the first character as-is
                result.append(remaining.removeFirst())
            }
        }

        if !result.isEmpty {
            committedText = result
        }
        buffer = remaining
        markedText = remaining
    }

    /// Returns the longest matching rule whose `latin` is a prefix of `text`.
    private func findLongestMatch(in text: String) -> TransliterationRule? {
        for key in sortedKeys {
            if text.hasPrefix(key), let char = map[key] {
                return TransliterationRule(latin: key, ethiopic: char)
            }
        }
        return nil
    }

    /// Returns true if `prefix` is the beginning of at least one rule key.
    private func couldMatchPrefix(_ prefix: String) -> Bool {
        for key in sortedKeys where key.hasPrefix(prefix) && key != prefix {
            return true
        }
        return false
    }
}
