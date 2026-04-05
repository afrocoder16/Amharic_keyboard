import UIKit
import AmharicCore

protocol KeyboardTabBarDelegate: AnyObject {
    func tabBar(_ tabBar: KeyboardTabBar, didSelectMode mode: KeyboardMode)
}

/// Three-tab bar at the top of the keyboard: Keyboard / Draw / Translate.
final class KeyboardTabBar: UIView {

    weak var delegate: KeyboardTabBarDelegate?

    private(set) var selectedMode: KeyboardMode = .typing {
        didSet { updateSelection() }
    }

    private var buttons: [UIButton] = []
    private let indicator = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Private

    private func setup() {
        backgroundColor = KeyboardTheme.tabBarBackground

        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])

        for mode in KeyboardMode.allCases {
            let btn = UIButton(type: .system)
            btn.setTitle(mode.title, for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .medium)
            btn.tag = mode.rawValue
            btn.addTarget(self, action: #selector(tabTapped(_:)), for: .touchUpInside)
            stack.addArrangedSubview(btn)
            buttons.append(btn)
        }

        // Sliding indicator
        indicator.backgroundColor = KeyboardTheme.tabActive
        indicator.layer.cornerRadius = 1
        indicator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(indicator)
        indicator.heightAnchor.constraint(equalToConstant: 2).isActive = true
        indicator.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        updateSelection()
    }

    private func updateSelection() {
        for btn in buttons {
            let isSelected = btn.tag == selectedMode.rawValue
            btn.setTitleColor(isSelected ? KeyboardTheme.tabActive : KeyboardTheme.tabInactive, for: .normal)
        }

        let idx = selectedMode.rawValue
        guard idx < buttons.count else { return }
        let btn = buttons[idx]

        UIView.animate(withDuration: 0.2) {
            self.indicator.frame = CGRect(
                x: btn.frame.origin.x + 8,
                y: self.bounds.height - 2,
                width: btn.bounds.width - 16,
                height: 2
            )
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateSelection()
    }

    @objc private func tabTapped(_ sender: UIButton) {
        guard let mode = KeyboardMode(rawValue: sender.tag) else { return }
        selectedMode = mode
        delegate?.tabBar(self, didSelectMode: mode)
    }
}
