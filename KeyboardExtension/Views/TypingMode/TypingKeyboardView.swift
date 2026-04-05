import UIKit
import AmharicCore

protocol TypingKeyboardDelegate: AnyObject {
    func typingKeyboard(_ view: TypingKeyboardView, didInsertText text: String)
    func typingKeyboardDidTapDelete(_ view: TypingKeyboardView)
    func typingKeyboardDidTapReturn(_ view: TypingKeyboardView)
    func typingKeyboardDidTapGlobe(_ view: TypingKeyboardView)
    func typingKeyboard(_ view: TypingKeyboardView, didCommitWord word: String)
    func typingKeyboard(_ view: TypingKeyboardView, didUpdateMarkedText text: String)
}

/// The main QWERTY-style Latin → Ethiopic transliteration keyboard.
final class TypingKeyboardView: UIView {

    weak var delegate: TypingKeyboardDelegate?

    private let engine = TransliterationEngine()
    private var observation: [Any] = []
    private var isShifted = false

    // MARK: - Layout rows

    private static let row1 = ["q","w","e","r","t","y","u","i","o","p"]
    private static let row2 = ["a","s","d","f","g","h","j","k","l"]
    private static let row3 = ["z","x","c","v","b","n","m"]

    private var row1View: LatinRowView!
    private var row2View: LatinRowView!
    private var row3View: LatinRowView!
    private var utilityView: UtilityRowView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        observeEngine()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Setup

    private func setup() {
        backgroundColor = KeyboardTheme.background

        row1View = LatinRowView(keys: Self.row1)
        row2View = LatinRowView(keys: Self.row2)
        row3View = LatinRowView(keys: Self.row3)
        utilityView = UtilityRowView()

        [row1View!, row2View!, row3View!, utilityView!].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }

        row1View.keyDelegate = self
        row2View.keyDelegate = self
        row3View.keyDelegate = self
        utilityView.delegate = self

        let rowHeight = KeyboardTheme.keyHeight

        NSLayoutConstraint.activate([
            row1View.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            row1View.leadingAnchor.constraint(equalTo: leadingAnchor),
            row1View.trailingAnchor.constraint(equalTo: trailingAnchor),
            row1View.heightAnchor.constraint(equalToConstant: rowHeight),

            row2View.topAnchor.constraint(equalTo: row1View.bottomAnchor, constant: 4),
            row2View.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            row2View.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            row2View.heightAnchor.constraint(equalToConstant: rowHeight),

            row3View.topAnchor.constraint(equalTo: row2View.bottomAnchor, constant: 4),
            row3View.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 50),
            row3View.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -50),
            row3View.heightAnchor.constraint(equalToConstant: rowHeight),

            utilityView.topAnchor.constraint(equalTo: row3View.bottomAnchor, constant: 4),
            utilityView.leadingAnchor.constraint(equalTo: leadingAnchor),
            utilityView.trailingAnchor.constraint(equalTo: trailingAnchor),
            utilityView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
        ])
    }

    // MARK: - Engine Observation

    private func observeEngine() {
        let c1 = engine.$markedText.sink { [weak self] text in
            self?.delegate?.typingKeyboard(self!, didUpdateMarkedText: text)
            self?.utilityView.spaceLabelText = text.isEmpty ? "space" : text
        }
        let c2 = engine.$committedText.sink { [weak self] text in
            guard !text.isEmpty, let self = self else { return }
            if text == "\u{08}" {
                self.delegate?.typingKeyboardDidTapDelete(self)
            } else {
                self.delegate?.typingKeyboard(self, didInsertText: text)
            }
        }
        // Store as Any to avoid import of Combine in non-Combine contexts
        observation.append(c1)
        observation.append(c2)
    }
}

// MARK: - KeyButtonDelegate

extension TypingKeyboardView: KeyButtonDelegate {
    func keyButton(_ button: KeyButton, didTapKey key: String) {
        let char = isShifted ? key.uppercased() : key.lowercased()
        // Feed into transliteration engine
        engine.process(key: char)

        if isShifted {
            isShifted = false
            // Update button appearance if needed
        }
    }
}

// MARK: - UtilityRowDelegate

extension TypingKeyboardView: UtilityRowDelegate {

    func utilityRowDidTapShift(_ row: UtilityRowView) {
        isShifted.toggle()
    }

    func utilityRowDidTapDelete(_ row: UtilityRowView) {
        engine.process(key: "\u{08}")
    }

    func utilityRowDidTapSpace(_ row: UtilityRowView) {
        let flushed = engine.flush()
        if !flushed.isEmpty {
            delegate?.typingKeyboard(self, didCommitWord: flushed)
        }
        delegate?.typingKeyboard(self, didInsertText: " ")
    }

    func utilityRowDidTapReturn(_ row: UtilityRowView) {
        let flushed = engine.flush()
        if !flushed.isEmpty {
            delegate?.typingKeyboard(self, didCommitWord: flushed)
        }
        delegate?.typingKeyboardDidTapReturn(self)
    }

    func utilityRowDidTapGlobe(_ row: UtilityRowView) {
        delegate?.typingKeyboardDidTapGlobe(self)
    }

    func utilityRowDidTapNumbers(_ row: UtilityRowView) {
        // Future: switch to numbers/punctuation page
    }
}
