import UIKit

protocol UtilityRowDelegate: AnyObject {
    func utilityRowDidTapShift(_ row: UtilityRowView)
    func utilityRowDidTapDelete(_ row: UtilityRowView)
    func utilityRowDidTapSpace(_ row: UtilityRowView)
    func utilityRowDidTapReturn(_ row: UtilityRowView)
    func utilityRowDidTapGlobe(_ row: UtilityRowView)
    func utilityRowDidTapNumbers(_ row: UtilityRowView)
}

/// Bottom two rows: shift/delete row + space/return row.
final class UtilityRowView: UIView {

    weak var delegate: UtilityRowDelegate?

    /// Label on the space bar — used to preview pending Ethiopic text.
    var spaceLabelText: String = "space" {
        didSet { spaceButton.setTitle(spaceLabelText, for: .normal) }
    }

    private let spaceButton  = UIButton(type: .system)
    private let shiftButton  = UIButton(type: .system)
    private let deleteButton = UIButton(type: .system)
    private let returnButton = UIButton(type: .system)
    private let globeButton  = UIButton(type: .system)
    private let numbersButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        backgroundColor = .clear

        // Row 3: shift + 7 letter placeholders + delete
        let row3 = UIStackView()
        row3.axis = .horizontal
        row3.spacing = KeyboardTheme.keySpacing
        row3.translatesAutoresizingMaskIntoConstraints = false

        configure(shiftButton,  title: "⇧", isSpecial: true)
        configure(deleteButton, title: "⌫", isSpecial: true)

        let row3Spacer = UIView()
        row3Spacer.backgroundColor = .clear

        row3.addArrangedSubview(shiftButton)
        row3.addArrangedSubview(row3Spacer)
        row3.addArrangedSubview(deleteButton)

        shiftButton.widthAnchor.constraint(equalToConstant: 42).isActive = true
        deleteButton.widthAnchor.constraint(equalToConstant: 42).isActive = true

        // Row 4: numbers + globe + space + return
        let row4 = UIStackView()
        row4.axis = .horizontal
        row4.spacing = KeyboardTheme.keySpacing
        row4.translatesAutoresizingMaskIntoConstraints = false

        configure(numbersButton, title: "123", isSpecial: true)
        configure(globeButton,   title: "🌐", isSpecial: true)
        configure(spaceButton,   title: "space", isSpecial: false)
        configure(returnButton,  title: "return", isSpecial: true)

        numbersButton.widthAnchor.constraint(equalToConstant: 42).isActive = true
        globeButton.widthAnchor.constraint(equalToConstant: 42).isActive = true
        returnButton.widthAnchor.constraint(equalToConstant: 88).isActive = true

        row4.addArrangedSubview(numbersButton)
        row4.addArrangedSubview(globeButton)
        row4.addArrangedSubview(spaceButton)
        row4.addArrangedSubview(returnButton)

        let vStack = UIStackView(arrangedSubviews: [row3, row4])
        vStack.axis = .vertical
        vStack.spacing = 0
        vStack.distribution = .fillEqually
        vStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(vStack)

        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: topAnchor),
            vStack.bottomAnchor.constraint(equalTo: bottomAnchor),
            vStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            vStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
        ])

        shiftButton.addTarget(self,   action: #selector(shiftTapped),   for: .touchUpInside)
        deleteButton.addTarget(self,  action: #selector(deleteTapped),  for: .touchUpInside)
        spaceButton.addTarget(self,   action: #selector(spaceTapped),   for: .touchUpInside)
        returnButton.addTarget(self,  action: #selector(returnTapped),  for: .touchUpInside)
        globeButton.addTarget(self,   action: #selector(globeTapped),   for: .touchUpInside)
        numbersButton.addTarget(self, action: #selector(numbersTapped), for: .touchUpInside)
    }

    private func configure(_ btn: UIButton, title: String, isSpecial: Bool) {
        btn.setTitle(title, for: .normal)
        btn.titleLabel?.font = isSpecial
            ? UIFont.systemFont(ofSize: 15, weight: .regular)
            : KeyboardTheme.keyFont()
        btn.setTitleColor(KeyboardTheme.keyLabel, for: .normal)
        btn.backgroundColor = isSpecial ? KeyboardTheme.specialKeyBackground : KeyboardTheme.keyBackground
        btn.layer.cornerRadius = KeyboardTheme.keyCornerRadius
        btn.layer.shadowColor  = KeyboardTheme.keyShadow.cgColor
        btn.layer.shadowOffset = CGSize(width: 0, height: 1)
        btn.layer.shadowRadius = 0
        btn.layer.shadowOpacity = 1
    }

    @objc private func shiftTapped()   { delegate?.utilityRowDidTapShift(self) }
    @objc private func deleteTapped()  { delegate?.utilityRowDidTapDelete(self) }
    @objc private func spaceTapped()   { delegate?.utilityRowDidTapSpace(self) }
    @objc private func returnTapped()  { delegate?.utilityRowDidTapReturn(self) }
    @objc private func globeTapped()   { delegate?.utilityRowDidTapGlobe(self) }
    @objc private func numbersTapped() { delegate?.utilityRowDidTapNumbers(self) }
}
