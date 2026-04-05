import Foundation

public struct AmharicWord: Hashable {
    public let text: String
    public let frequency: Int

    public init(text: String, frequency: Int) {
        self.text = text
        self.frequency = frequency
    }
}
