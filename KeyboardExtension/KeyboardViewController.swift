import UIKit
import AmharicCore

/// The root UIInputViewController for the Amharic custom keyboard extension.
/// All text insertion, deletion, and marked text operations flow through this class.
class KeyboardViewController: UIInputViewController {

    private var rootKeyboardView: RootKeyboardView!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupKeyboardView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        rootKeyboardView.hasFullAccess = hasFullAccess
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Ensure the keyboard height is applied after layout
        updateKeyboardHeight(KeyboardMode.typing.preferredHeight)
    }

    // MARK: - Setup

    private func setupKeyboardView() {
        rootKeyboardView = RootKeyboardView()
        rootKeyboardView.delegate = self
        rootKeyboardView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(rootKeyboardView)

        NSLayoutConstraint.activate([
            rootKeyboardView.topAnchor.constraint(equalTo: view.topAnchor),
            rootKeyboardView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            rootKeyboardView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            rootKeyboardView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    // MARK: - Text Document Proxy Helpers

    private func insertText(_ text: String) {
        textDocumentProxy.insertText(text)
    }

    private func deleteBackward() {
        textDocumentProxy.deleteBackward()
    }

    private func setMarkedText(_ text: String) {
        textDocumentProxy.setMarkedText(text, selectedRange: NSRange(location: text.count, length: 0))
    }

    private func commitMarkedText() {
        textDocumentProxy.unmarkText()
    }

    // MARK: - Height Management

    private func updateKeyboardHeight(_ height: CGFloat) {
        // UIInputViewController manages its own size; adjust via heightAnchor
        view.heightAnchor.constraint(equalToConstant: height).isActive = true
    }

    // MARK: - UITextInput Callbacks

    override func textWillChange(_ textInput: UITextInput?) {
        // Can be used to reset state if needed
    }

    override func textDidChange(_ textInput: UITextInput?) {
        // Feed document context to prediction engine if needed
    }
}

// MARK: - RootKeyboardViewDelegate

extension KeyboardViewController: RootKeyboardViewDelegate {

    func rootKeyboard(_ view: RootKeyboardView, didInsertText text: String) {
        // If there's marked text, commit it first
        if textDocumentProxy.hasText {
            commitMarkedText()
        }
        insertText(text)
    }

    func rootKeyboardDidTapDelete(_ view: RootKeyboardView) {
        // Check if there's marked text to clear first
        if let marked = textDocumentProxy.selectedText, !marked.isEmpty {
            textDocumentProxy.insertText("")
        } else {
            deleteBackward()
        }
    }

    func rootKeyboardDidTapReturn(_ view: RootKeyboardView) {
        insertText("\n")
    }

    func rootKeyboardDidTapGlobe(_ view: RootKeyboardView) {
        advanceToNextInputMode()
    }

    func rootKeyboard(_ view: RootKeyboardView, didChangeHeight height: CGFloat) {
        updateKeyboardHeight(height)
    }

    func rootKeyboard(_ view: RootKeyboardView, didUpdateMarkedText text: String) {
        setMarkedText(text)
    }

    func rootKeyboard(_ view: RootKeyboardView, didCommitWord word: String) {
        commitMarkedText()
    }
}
