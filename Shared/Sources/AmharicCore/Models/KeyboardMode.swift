import Foundation

public enum KeyboardMode: Int, CaseIterable {
    case typing
    case handwriting
    case translation

    public var title: String {
        switch self {
        case .typing:       return "Keyboard"
        case .handwriting:  return "Draw"
        case .translation:  return "Translate"
        }
    }

    public var icon: String {
        switch self {
        case .typing:       return "keyboard"
        case .handwriting:  return "pencil.and.outline"
        case .translation:  return "globe"
        }
    }

    /// Preferred keyboard height in points for each mode.
    public var preferredHeight: CGFloat {
        switch self {
        case .typing:       return 260
        case .handwriting:  return 340
        case .translation:  return 320
        }
    }
}
