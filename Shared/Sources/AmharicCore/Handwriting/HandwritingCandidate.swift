import Foundation

/// A single recognition candidate returned by the StrokeRecognizer.
public struct HandwritingCandidate: Identifiable {
    public let id = UUID()
    /// The recognized Ethiopic character.
    public let character: Character
    /// Confidence score in [0, 1]. Higher is better.
    public let confidence: Double

    public init(character: Character, confidence: Double) {
        self.character = character
        self.confidence = confidence
    }
}
