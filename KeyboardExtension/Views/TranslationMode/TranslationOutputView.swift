import UIKit

protocol TranslationOutputDelegate: AnyObject {
    func translationOutput(_ view: TranslationOutputView, didTapInsertText text: String)
}

/// Read-only output area. Tap the translated text to insert it into the host text field.
final class TranslationOutputView: UIView {

    weak var delegate: TranslationOutputDelegate?

    var text: String = "" {
        didSet {
            outputLabel.text = text
            outputLabel.textColor = text.isEmpty ? UIColor.placeholderText : UIColor.systemBlue
            activityIndicator.stopAnimating()
        }
    }

    var languageLabel: String = "English" {
        didSet { langLabel.text = languageLabel }
    }

    var isLoading: Bool = false {
        didSet {
            if isLoading {
                outputLabel.text = ""
                activityIndicator.startAnimating()
            } else {
                activityIndicator.stopAnimating()
            }
        }
    }

    private let langLabel         = UILabel()
    private let outputLabel       = UILabel()
    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        backgroundColor = UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(white: 0.08, alpha: 1)
                : UIColor(white: 0.93, alpha: 1)
        }
        layer.cornerRadius = 8

        langLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        langLabel.textColor = UIColor.secondaryLabel
        langLabel.text = languageLabel
        langLabel.translatesAutoresizingMaskIntoConstraints = false

        outputLabel.font = UIFont.systemFont(ofSize: 18)
        outputLabel.textColor = UIColor.systemBlue
        outputLabel.text = text.isEmpty ? "Translation will appear here" : text
        outputLabel.numberOfLines = 0
        outputLabel.translatesAutoresizingMaskIntoConstraints = false

        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        addSubview(langLabel)
        addSubview(outputLabel)
        addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            langLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            langLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),

            outputLabel.topAnchor.constraint(equalTo: langLabel.bottomAnchor, constant: 4),
            outputLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            outputLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            outputLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -8),

            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])

        let tap = UITapGestureRecognizer(target: self, action: #selector(outputTapped))
        addGestureRecognizer(tap)
    }

    @objc private func outputTapped() {
        guard !text.isEmpty else { return }
        delegate?.translationOutput(self, didTapInsertText: text)
    }
}
