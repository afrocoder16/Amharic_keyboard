import UIKit

/// A horizontal row of Latin alphabet key buttons.
final class LatinRowView: UIView {

    weak var keyDelegate: KeyButtonDelegate?

    private let keys: [String]
    private var buttons: [KeyButton] = []

    init(keys: [String]) {
        self.keys = keys
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = KeyboardTheme.keySpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
        ])

        for key in keys {
            let btn = KeyButton(key: key)
            btn.delegate = keyDelegate
            stack.addArrangedSubview(btn)
            buttons.append(btn)
        }
    }

    func updateDelegates() {
        for btn in buttons {
            btn.delegate = keyDelegate
        }
    }
}
