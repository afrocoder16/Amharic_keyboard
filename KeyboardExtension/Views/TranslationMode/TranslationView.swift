import UIKit
import AmharicCore

protocol TranslationViewDelegate: AnyObject {
    func translationView(_ view: TranslationView, didInsertText text: String)
    func translationViewNeedsFullAccess(_ view: TranslationView)
}

/// Full translation panel: input (Amharic or English) → output (English or Amharic).
final class TranslationView: UIView {

    weak var delegate: TranslationViewDelegate?

    /// Set to false to disable translation (e.g. when Full Access not granted).
    var hasFullAccess: Bool = false {
        didSet { updateFullAccessState() }
    }

    private let inputView    = TranslationInputView()
    private let outputView   = TranslationOutputView()
    private let toggleButton = UIButton(type: .system)
    private let errorLabel   = UILabel()

    private var sourceLang = "am"
    private var targetLang = "en"

    private let translationService: TranslationService = GoogleTranslateClient()
    private var translationTask: Task<Void, Never>?
    private var debounceTimer: Timer?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Setup

    private func setup() {
        backgroundColor = KeyboardTheme.background

        inputView.delegate  = self
        outputView.delegate = self

        inputView.languageLabel  = "Amharic"
        outputView.languageLabel = "English"

        toggleButton.setTitle("⇅", for: .normal)
        toggleButton.titleLabel?.font = UIFont.systemFont(ofSize: 22)
        toggleButton.addTarget(self, action: #selector(toggleLanguages), for: .touchUpInside)

        errorLabel.font = UIFont.systemFont(ofSize: 12)
        errorLabel.textColor = .systemOrange
        errorLabel.numberOfLines = 0
        errorLabel.textAlignment = .center
        errorLabel.isHidden = true

        [inputView, toggleButton, outputView, errorLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }

        NSLayoutConstraint.activate([
            inputView.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            inputView.leadingAnchor.constraint(equalTo: leadingAnchor),
            inputView.trailingAnchor.constraint(equalTo: trailingAnchor),
            inputView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.38),

            toggleButton.topAnchor.constraint(equalTo: inputView.bottomAnchor, constant: 2),
            toggleButton.centerXAnchor.constraint(equalTo: centerXAnchor),

            outputView.topAnchor.constraint(equalTo: toggleButton.bottomAnchor, constant: 2),
            outputView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            outputView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            outputView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.38),

            errorLabel.topAnchor.constraint(equalTo: outputView.bottomAnchor, constant: 4),
            errorLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            errorLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
        ])
    }

    // MARK: - Language Toggle

    @objc private func toggleLanguages() {
        swap(&sourceLang, &targetLang)
        inputView.languageLabel  = sourceLang == "am" ? "Amharic" : "English"
        outputView.languageLabel = targetLang == "en" ? "English" : "Amharic"
        let currentInput = inputView.text
        inputView.text = outputView.text
        outputView.text = currentInput
        triggerTranslation(text: inputView.text)
    }

    // MARK: - Translation

    private func triggerTranslation(text: String) {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else {
            outputView.text = ""
            return
        }
        guard hasFullAccess else {
            showError(TranslationError.noFullAccess.errorDescription ?? "")
            return
        }

        debounceTimer?.invalidate()
        debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false) { [weak self] _ in
            self?.performTranslation(text: text)
        }
    }

    private func performTranslation(text: String) {
        translationTask?.cancel()
        outputView.isLoading = true
        errorLabel.isHidden = true

        translationTask = Task { [weak self] in
            guard let self else { return }
            do {
                let result = try await translationService.translate(
                    text: text, from: sourceLang, to: targetLang)
                await MainActor.run {
                    self.outputView.text = result
                    self.outputView.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.outputView.isLoading = false
                    self.showError(error.localizedDescription)
                }
            }
        }
    }

    private func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
    }

    private func updateFullAccessState() {
        if !hasFullAccess {
            showError("Enable 'Allow Full Access' in Settings to use translation.")
        } else {
            errorLabel.isHidden = true
        }
    }
}

// MARK: - TranslationInputDelegate

extension TranslationView: TranslationInputDelegate {
    func translationInput(_ view: TranslationInputView, didChangeText text: String) {
        triggerTranslation(text: text)
    }

    func translationInputDidTapPaste(_ view: TranslationInputView) {
        if let str = UIPasteboard.general.string {
            inputView.text = str
            triggerTranslation(text: str)
        }
    }
}

// MARK: - TranslationOutputDelegate

extension TranslationView: TranslationOutputDelegate {
    func translationOutput(_ view: TranslationOutputView, didTapInsertText text: String) {
        delegate?.translationView(self, didInsertText: text)
    }
}
