import UIKit
import AmharicCore

protocol KeyButtonDelegate: AnyObject {
    func keyButton(_ button: KeyButton, didTapKey key: String)
}

/// A single keyboard key button.
/// Shows the primary Latin label and optionally a small Ethiopic hint.
final class KeyButton: UIView {

    weak var delegate: KeyButtonDelegate?

    let key: String

    private let primaryLabel   = UILabel()
    private let ethiopicHint   = UILabel()
    private let backgroundView = UIView()
    private var popupView: UIView?

    init(key: String) {
        self.key = key
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Setup

    private func setup() {
        // Shadow host
        layer.shadowColor  = KeyboardTheme.keyShadow.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 0
        layer.shadowOpacity = 1

        // Background
        backgroundView.backgroundColor   = KeyboardTheme.keyBackground
        backgroundView.layer.cornerRadius = KeyboardTheme.keyCornerRadius
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backgroundView)

        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: topAnchor, constant: 3),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -3),
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 3),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -3),
        ])

        // Primary label
        primaryLabel.text = key.uppercased()
        primaryLabel.font = KeyboardTheme.keyFont()
        primaryLabel.textColor = KeyboardTheme.keyLabel
        primaryLabel.textAlignment = .center
        primaryLabel.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.addSubview(primaryLabel)

        // Ethiopic hint
        let hintChar = EthiopicCharacterMap.map[key.lowercased()].map(String.init) ?? ""
        ethiopicHint.text = hintChar
        ethiopicHint.font = KeyboardTheme.ethiopicHintFont()
        ethiopicHint.textColor = KeyboardTheme.tabInactive
        ethiopicHint.textAlignment = .center
        ethiopicHint.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.addSubview(ethiopicHint)

        NSLayoutConstraint.activate([
            primaryLabel.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
            primaryLabel.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor, constant: -4),

            ethiopicHint.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
            ethiopicHint.topAnchor.constraint(equalTo: primaryLabel.bottomAnchor, constant: 1),
        ])

        // Touch recognizer
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)

        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLong(_:)))
        longPress.minimumPressDuration = 0.08
        addGestureRecognizer(longPress)
    }

    // MARK: - Interaction

    @objc private func handleTap() {
        animatePress()
        delegate?.keyButton(self, didTapKey: key)
    }

    @objc private func handleLong(_ gr: UILongPressGestureRecognizer) {
        switch gr.state {
        case .began:
            showPopup()
            animatePress()
        case .ended, .cancelled, .failed:
            hidePopup()
            delegate?.keyButton(self, didTapKey: key)
        default:
            break
        }
    }

    private func animatePress() {
        UIView.animate(withDuration: 0.05, animations: {
            self.backgroundView.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.backgroundView.transform = .identity
            }
        }
    }

    private func showPopup() {
        let popup = UIView()
        popup.backgroundColor = KeyboardTheme.keyBackground
        popup.layer.cornerRadius = 8
        popup.layer.shadowColor  = UIColor.black.cgColor
        popup.layer.shadowOpacity = 0.2
        popup.layer.shadowRadius  = 4
        popup.layer.shadowOffset  = .zero

        let lbl = UILabel()
        lbl.text = key.uppercased()
        lbl.font = UIFont.systemFont(ofSize: 26, weight: .regular)
        lbl.textColor = KeyboardTheme.keyLabel
        lbl.translatesAutoresizingMaskIntoConstraints = false
        popup.addSubview(lbl)

        NSLayoutConstraint.activate([
            lbl.centerXAnchor.constraint(equalTo: popup.centerXAnchor),
            lbl.centerYAnchor.constraint(equalTo: popup.centerYAnchor),
        ])

        popup.translatesAutoresizingMaskIntoConstraints = false
        superview?.addSubview(popup)

        NSLayoutConstraint.activate([
            popup.widthAnchor.constraint(equalToConstant: 44),
            popup.heightAnchor.constraint(equalToConstant: 54),
            popup.centerXAnchor.constraint(equalTo: centerXAnchor),
            popup.bottomAnchor.constraint(equalTo: topAnchor, constant: -4),
        ])

        popupView = popup
    }

    private func hidePopup() {
        popupView?.removeFromSuperview()
        popupView = nil
    }
}
