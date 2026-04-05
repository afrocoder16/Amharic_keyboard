import UIKit

protocol TranslationInputDelegate: AnyObject {
    func translationInput(_ view: TranslationInputView, didChangeText text: String)
    func translationInputDidTapPaste(_ view: TranslationInputView)
}

/// Editable text input area for the translation mode.
final class TranslationInputView: UIView {

    weak var delegate: TranslationInputDelegate?

    var text: String {
        get { textView.text }
        set { textView.text = newValue; updatePlaceholder() }
    }

    var languageLabel: String = "Amharic" {
        didSet { langLabel.text = languageLabel }
    }

    private let textView    = UITextView()
    private let langLabel   = UILabel()
    private let placeholder = UILabel()
    private let pasteButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        backgroundColor = KeyboardTheme.background

        langLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        langLabel.textColor = UIColor.systemBlue
        langLabel.text = languageLabel
        langLabel.translatesAutoresizingMaskIntoConstraints = false

        pasteButton.setTitle("Paste", for: .normal)
        pasteButton.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        pasteButton.addTarget(self, action: #selector(pasteTapped), for: .touchUpInside)
        pasteButton.translatesAutoresizingMaskIntoConstraints = false

        textView.font = UIFont.systemFont(ofSize: 18)
        textView.backgroundColor = .clear
        textView.textColor = KeyboardTheme.keyLabel
        textView.isScrollEnabled = true
        textView.delegate = self
        textView.translatesAutoresizingMaskIntoConstraints = false

        placeholder.text = "Enter text"
        placeholder.font = UIFont.systemFont(ofSize: 18)
        placeholder.textColor = UIColor.placeholderText
        placeholder.translatesAutoresizingMaskIntoConstraints = false

        let topBar = UIView()
        topBar.translatesAutoresizingMaskIntoConstraints = false
        topBar.addSubview(langLabel)
        topBar.addSubview(pasteButton)

        NSLayoutConstraint.activate([
            langLabel.leadingAnchor.constraint(equalTo: topBar.leadingAnchor, constant: 8),
            langLabel.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),
            pasteButton.trailingAnchor.constraint(equalTo: topBar.trailingAnchor, constant: -8),
            pasteButton.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),
            topBar.heightAnchor.constraint(equalToConstant: 30),
        ])

        addSubview(topBar)
        addSubview(textView)
        addSubview(placeholder)

        NSLayoutConstraint.activate([
            topBar.topAnchor.constraint(equalTo: topAnchor),
            topBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            topBar.trailingAnchor.constraint(equalTo: trailingAnchor),

            textView.topAnchor.constraint(equalTo: topBar.bottomAnchor, constant: 4),
            textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            textView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            textView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),

            placeholder.topAnchor.constraint(equalTo: textView.topAnchor, constant: 8),
            placeholder.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 5),
        ])
    }

    private func updatePlaceholder() {
        placeholder.isHidden = !textView.text.isEmpty
    }

    @objc private func pasteTapped() {
        delegate?.translationInputDidTapPaste(self)
    }
}

extension TranslationInputView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        updatePlaceholder()
        delegate?.translationInput(self, didChangeText: textView.text)
    }
}
