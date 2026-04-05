import UIKit
import AmharicCore

protocol CandidateBarDelegate: AnyObject {
    func candidateBar(_ bar: CandidateBarView, didSelectCandidate character: Character)
}

/// Horizontal bar showing top-N handwriting recognition candidates.
final class CandidateBarView: UIView {

    weak var delegate: CandidateBarDelegate?

    private let stackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Public

    func update(candidates: [HandwritingCandidate]) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for (index, candidate) in candidates.enumerated() {
            if index > 0 {
                let sep = UIView()
                sep.backgroundColor = UIColor.separator
                sep.widthAnchor.constraint(equalToConstant: 0.5).isActive = true
                stackView.addArrangedSubview(sep)
            }
            let btn = makeCandidateButton(for: candidate)
            stackView.addArrangedSubview(btn)
        }
    }

    func clearCandidates() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }

    // MARK: - Private

    private func setup() {
        backgroundColor = KeyboardTheme.suggestionBar

        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])

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

    private func makeCandidateButton(for candidate: HandwritingCandidate) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitle(String(candidate.character), for: .normal)
        btn.titleLabel?.font = KeyboardTheme.candidateFont()
        btn.setTitleColor(KeyboardTheme.keyLabel, for: .normal)
        btn.tag = Int(candidate.character.asciiValue ?? 0)
        // Store character using associated object pattern via custom subclass not needed —
        // we pass it directly in the action
        btn.addAction(UIAction { [weak self, character = candidate.character] _ in
            self?.delegate?.candidateBar(self!, didSelectCandidate: character)
        }, for: .touchUpInside)
        return btn
    }
}
