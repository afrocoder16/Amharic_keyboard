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

    /// Buffer of Ethiopic characters accumulated from handwriting strokes.
    /// These are shown as marked (underlined) text in the host document while
    /// the user keeps drawing. The suggestion bar shows word completions based
    /// on this buffer. Tapping a suggestion replaces the buffer with the full word.
    private var handwritingBuffer: String = ""

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
        // Flush handwriting buffer when leaving handwriting mode
        if currentMode == .handwriting && mode != .handwriting {
            flushHandwritingBuffer()
        }
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

    // MARK: - Handwriting Buffer

    /// Append a newly recognized character to the handwriting buffer.
    /// Updates marked text in the document and refreshes word predictions.
    private func appendToHandwritingBuffer(_ character: Character) {
        handwritingBuffer.append(character)
        // Show the accumulated characters as underlined (marked) text
        delegate?.rootKeyboard(self, didUpdateMarkedText: handwritingBuffer)
        // Update the word preview label inside the handwriting view
        handwritingView.currentWordPreview = handwritingBuffer
        // Feed the buffer into prediction engine for prefix completions
        predictionEngine.updateMidWord(prefix: handwritingBuffer)
        suggestionBar.update(suggestions: predictionEngine.suggestions)
    }

    /// Commit all buffered handwriting characters, optionally replacing with a word.
    private func commitHandwritingBuffer(replacingWith word: String? = nil) {
        guard !handwritingBuffer.isEmpty else { return }
        let toInsert = word ?? handwritingBuffer
        handwritingBuffer = ""
        handwritingView.currentWordPreview = ""
        // Insert the committed text (clears marked text automatically)
        delegate?.rootKeyboard(self, didInsertText: toInsert)
        predictionEngine.wordCommitted(toInsert.trimmingCharacters(in: .whitespaces))
        suggestionBar.update(suggestions: predictionEngine.suggestions)
    }

    /// Flush buffer as-is (e.g. when switching modes or pressing space).
    private func flushHandwritingBuffer() {
        commitHandwritingBuffer()
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
        if currentMode == .handwriting && !handwritingBuffer.isEmpty {
            // Replace the accumulated handwriting characters with the selected word
            commitHandwritingBuffer(replacingWith: word + " ")
        } else {
            delegate?.rootKeyboard(self, didInsertText: word + " ")
            predictionEngine.wordCommitted(word)
            suggestionBar.update(suggestions: predictionEngine.suggestions)
        }
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
    /// Called when the user taps one of the top-5 recognition candidates.
    /// The character is added to the accumulation buffer, not inserted directly.
    /// The suggestion bar updates with Amharic word completions for the buffer.
    func handwritingView(_ view: HandwritingView, didSelectCharacter character: Character) {
        appendToHandwritingBuffer(character)
    }

    /// Called when the user taps the space/commit button in handwriting mode.
    func handwritingViewDidTapSpace(_ view: HandwritingView) {
        commitHandwritingBuffer(replacingWith: (handwritingBuffer.isEmpty ? nil : handwritingBuffer + " "))
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
