import UIKit

/// Centralized color and font definitions for the Amharic keyboard.
public enum KeyboardTheme {

    // MARK: - Colors

    public static var background: UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(white: 0.12, alpha: 1)
                : UIColor(white: 0.82, alpha: 1)
        }
    }

    public static var keyBackground: UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(white: 0.28, alpha: 1)
                : UIColor.white
        }
    }

    public static var specialKeyBackground: UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(white: 0.18, alpha: 1)
                : UIColor(white: 0.70, alpha: 1)
        }
    }

    public static var keyLabel: UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .dark ? .white : .black
        }
    }

    public static var keyShadow: UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(white: 0.0, alpha: 0.5)
                : UIColor(white: 0.5, alpha: 0.5)
        }
    }

    public static var suggestionBar: UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(white: 0.16, alpha: 1)
                : UIColor(white: 0.88, alpha: 1)
        }
    }

    public static var tabBarBackground: UIColor { suggestionBar }

    public static var tabActive: UIColor { UIColor.systemBlue }

    public static var tabInactive: UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(white: 0.55, alpha: 1)
                : UIColor(white: 0.45, alpha: 1)
        }
    }

    public static var canvasBackground: UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(white: 0.08, alpha: 1)
                : UIColor(white: 0.95, alpha: 1)
        }
    }

    public static var strokeColor: UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .dark ? .white : .black
        }
    }

    // MARK: - Fonts

    /// Font for Latin key labels.
    public static func keyFont(size: CGFloat = 17) -> UIFont {
        UIFont.systemFont(ofSize: size, weight: .regular)
    }

    /// Font for Ethiopic hint labels on keys.
    public static func ethiopicHintFont(size: CGFloat = 10) -> UIFont {
        UIFont.systemFont(ofSize: size, weight: .light)
    }

    /// Font for suggestion bar items.
    public static func suggestionFont(size: CGFloat = 16) -> UIFont {
        UIFont.systemFont(ofSize: size, weight: .regular)
    }

    /// Font for handwriting candidates.
    public static func candidateFont(size: CGFloat = 22) -> UIFont {
        UIFont.systemFont(ofSize: size, weight: .regular)
    }

    // MARK: - Dimensions

    public static let keyCornerRadius: CGFloat = 5
    public static let keyHeight: CGFloat = 42
    public static let tabBarHeight: CGFloat = 36
    public static let suggestionBarHeight: CGFloat = 38
    public static let keySpacing: CGFloat = 6
}
