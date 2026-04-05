import UIKit
import AmharicCore

protocol RootKeyboardViewDelegate: AnyObject {
    func rootKeyboard(_ view: RootKeyboardView, didInsertText text: String)
    func rootKeyboardDidTapDelete(_ view: RootKeyboardView)
    func rootKeyboardDidTapReturn(_ view: RootKeyboardView)
    func rootKeyboardDidTapGlobe(_ view: RootKeyboardView)
    func rootKeyboard(_ view: RootKeyboardView, didChangeHeight height: CGFloat)
    func rootKeyboard(_ view: RootKeyboardView, didUpdateMarkedText text: String)
    func rootKeyboard(_ view: RootKeyboardView, didCommitWord word: String)
}

/// The top-level keyboard view. Owns the tab bar, suggestion bar, and all mode views.
final class RootKeyboardView: UIView {

    weak var delegate: RootKeyboardViewDelegate?

    var hasFullAccess: Bool = false {
        didSet { translationView.hasFullAccess = hasFullAccess }
    }

    // MARK: - Subviews

    private let tabBar         = KeyboardTabBar()
    private let suggestionBar  = SuggestionBarView()
    private let typingView     = TypingKeyboardView()
    private let handwritingView = HandwritingView()
    private let translationView = TranslationView()

    private let predictionEngine = WordPredictionEngine()

    private var heightConstraint: NSLayoutConstraint!
    private var currentMode: KeyboardMode = .typing

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Setup

    private func setup() {
        backgroundColor = KeyboardTheme.background

        tabBar.delegate         = self
        suggestionBar.delegate  = self
        typingView.delegate     = self
        handwritingView.delegate = self
        translationView.delegate = self

        [tabBar, suggestionBar, typingView, handwritingView, translationView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }

        handwritingView.isHidden = true
        translationView.isHidden = true

        heightConstraint = heightAnchor.constraint(equalToConstant: KeyboardMode.typing.preferredHeight)
        heightConstraint.isActive = true

        NSLayoutConstraint.activate([
            tabBar.topAnchor.constraint(equalTo: topAnchor),
            tabBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            tabBar.trailingAnchor.constraint(equalTo: trailingAnchor),
            tabBar.heightAnchor.constraint(equalToConstant: KeyboardTheme.tabBarHeight),

            suggestionBar.topAnchor.constraint(equalTo: tabBar.bottomAnchor),
            suggestionBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            suggestionBar.trailingAnchor.constraint(equalTo: trailingAnchor),
            suggestionBar.heightAnchor.constraint(equalToConstant: KeyboardTheme.suggestionBarHeight),

            typingView.topAnchor.constraint(equalTo: suggestionBar.bottomAnchor),
            typingView.leadingAnchor.constraint(equalTo: leadingAnchor),
            typingView.trailingAnchor.constraint(equalTo: trailingAnchor),
            typingView.bottomAnchor.constraint(equalTo: bottomAnchor),

            handwritingView.topAnchor.constraint(equalTo: suggestionBar.bottomAnchor),
            handwritingView.leadingAnchor.constraint(equalTo: leadingAnchor),
            handwritingView.trailingAnchor.constraint(equalTo: trailingAnchor),
            handwritingView.bottomAnchor.constraint(equalTo: bottomAnchor),

            translationView.topAnchor.constraint(equalTo: tabBar.bottomAnchor),
            translationView.leadingAnchor.constraint(equalTo: leadingAnchor),
            translationView.trailingAnchor.constraint(equalTo: trailingAnchor),
            translationView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        observePredictions()
    }

    // MARK: - Mode Switching

    private func switchMode(_ mode: KeyboardMode) {
        currentMode = mode

        typingView.isHidden      = mode != .typing
        handwritingView.isHidden = mode != .handwriting
        translationView.isHidden = mode != .translation
        suggestionBar.isHidden   = mode == .translation

        UIView.animate(withDuration: 0.2) {
            self.heightConstraint.constant = mode.preferredHeight
            self.delegate?.rootKeyboard(self, didChangeHeight: mode.preferredHeight)
        }
    }

    // MARK: - Prediction Observation

    private func observePredictions() {
        // Using Combine sink via NotificationCenter equivalent for simplicity
        // In production use Combine .sink on predictionEngine.$suggestions
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("AmharicSuggestionsUpdated"),
            object: predictionEngine,
            queue: .main
        ) { [weak self] note in
            guard let words = note.userInfo?["words"] as? [String] else { return }
            self?.suggestionBar.update(suggestions: words)
        }
    }
}

// MARK: - KeyboardTabBarDelegate

extension RootKeyboardView: KeyboardTabBarDelegate {
    func tabBar(_ tabBar: KeyboardTabBar, didSelectMode mode: KeyboardMode) {
        switchMode(mode)
    }
}

// MARK: - SuggestionBarDelegate

extension RootKeyboardView: SuggestionBarDelegate {
    func suggestionBar(_ bar: SuggestionBarView, didSelectSuggestion word: String) {
        delegate?.rootKeyboard(self, didInsertText: word + " ")
        predictionEngine.wordCommitted(word)
    }
}

// MARK: - TypingKeyboardDelegate

extension RootKeyboardView: TypingKeyboardDelegate {
    func typingKeyboard(_ view: TypingKeyboardView, didInsertText text: String) {
        delegate?.rootKeyboard(self, didInsertText: text)
    }

    func typingKeyboardDidTapDelete(_ view: TypingKeyboardView) {
        delegate?.rootKeyboardDidTapDelete(self)
    }

    func typingKeyboardDidTapReturn(_ view: TypingKeyboardView) {
        delegate?.rootKeyboardDidTapReturn(self)
    }

    func typingKeyboardDidTapGlobe(_ view: TypingKeyboardView) {
        delegate?.rootKeyboardDidTapGlobe(self)
    }

    func typingKeyboard(_ view: TypingKeyboardView, didCommitWord word: String) {
        predictionEngine.wordCommitted(word)
        suggestionBar.update(suggestions: predictionEngine.suggestions)
        delegate?.rootKeyboard(self, didCommitWord: word)
    }

    func typingKeyboard(_ view: TypingKeyboardView, didUpdateMarkedText text: String) {
        predictionEngine.updateMidWord(prefix: text)
        suggestionBar.update(suggestions: predictionEngine.suggestions)
        delegate?.rootKeyboard(self, didUpdateMarkedText: text)
    }
}

// MARK: - HandwritingViewDelegate

extension RootKeyboardView: HandwritingViewDelegate {
    func handwritingView(_ view: HandwritingView, didSelectCharacter character: Character) {
        delegate?.rootKeyboard(self, didInsertText: String(character))
    }
}

// MARK: - TranslationViewDelegate

extension RootKeyboardView: TranslationViewDelegate {
    func translationView(_ view: TranslationView, didInsertText text: String) {
        delegate?.rootKeyboard(self, didInsertText: text)
    }

    func translationViewNeedsFullAccess(_ view: TranslationView) {
        // Handled by showing error in TranslationView itself
    }
}
