import Foundation

/// A single mapping from a Latin input sequence to an Ethiopic character.
public struct TransliterationRule: Comparable {
    /// The Latin key sequence (e.g. "sha", "ch", "l").
    public let latin: String
    /// The resulting Ethiopic character.
    public let ethiopic: Character
    /// Longer rules have higher priority in greedy matching.
    public var priority: Int { latin.count }

    public init(latin: String, ethiopic: Character) {
        self.latin = latin
        self.ethiopic = ethiopic
    }

    public static func < (lhs: TransliterationRule, rhs: TransliterationRule) -> Bool {
        lhs.priority < rhs.priority
    }
}
