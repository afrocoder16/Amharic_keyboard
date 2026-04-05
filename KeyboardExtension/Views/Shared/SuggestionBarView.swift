import UIKit

protocol SuggestionBarDelegate: AnyObject {
    func suggestionBar(_ bar: SuggestionBarView, didSelectSuggestion word: String)
}

/// Horizontal scrollable bar showing word prediction suggestions.
final class SuggestionBarView: UIView {

    weak var delegate: SuggestionBarDelegate?

    private let scrollView = UIScrollView()
    private let stackView  = UIStackView()
    private let dividerColor = UIColor.separator

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Public

    func update(suggestions: [String]) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for (index, word) in suggestions.enumerated() {
            if index > 0 {
                let sep = makeSeparator()
                stackView.addArrangedSubview(sep)
            }
            let btn = makeButton(title: word)
            stackView.addArrangedSubview(btn)
        }

        scrollView.contentOffset = .zero
    }

    // MARK: - Private

    private func setup() {
        backgroundColor = KeyboardTheme.suggestionBar

        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)

        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),

            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
        ])

        // Bottom border
        let border = UIView()
        border.backgroundColor = UIColor.separator
        border.translatesAutoresizingMaskIntoConstraints = false
        addSubview(border)
        NSLayoutConstraint.activate([
            border.leadingAnchor.constraint(equalTo: leadingAnchor),
            border.trailingAnchor.constraint(equalTo: trailingAnchor),
            border.bottomAnchor.constraint(equalTo: bottomAnchor),
            border.heightAnchor.constraint(equalToConstant: 0.5),
        ])
    }

    private func makeButton(title: String) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitle(title, for: .normal)
        btn.titleLabel?.font = KeyboardTheme.suggestionFont()
        btn.setTitleColor(KeyboardTheme.keyLabel, for: .normal)
        btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        btn.addTarget(self, action: #selector(suggestionTapped(_:)), for: .touchUpInside)
        return btn
    }

    private func makeSeparator() -> UIView {
        let v = UIView()
        v.backgroundColor = UIColor.separator
        v.translatesAutoresizingMaskIntoConstraints = false
        v.widthAnchor.constraint(equalToConstant: 0.5).isActive = true
        return v
    }

    @objc private func suggestionTapped(_ sender: UIButton) {
        guard let word = sender.currentTitle else { return }
        delegate?.suggestionBar(self, didSelectSuggestion: word)
    }
}
