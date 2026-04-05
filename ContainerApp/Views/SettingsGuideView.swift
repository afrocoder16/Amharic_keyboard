import UIKit

/// Standalone view showing a step-by-step visual guide to enabling the keyboard.
/// Can be presented modally or embedded in the onboarding flow.
final class SettingsGuideViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "How to Enable"
        view.backgroundColor = .systemBackground
        setupContent()
    }

    private func setupContent() {
        let steps: [(String, String)] = [
            ("Settings", "Open the Settings app on your iPhone."),
            ("General", "Scroll down and tap General."),
            ("Keyboard", "Tap Keyboard."),
            ("Keyboards", "Tap Keyboards, then tap Add New Keyboard…"),
            ("Amharic", "Scroll to find Amharic and tap it to add."),
            ("Allow Full Access", "Tap Amharic in your keyboards list.\nEnable \"Allow Full Access\" for translation features."),
        ]

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])

        for (index, (heading, detail)) in steps.enumerated() {
            let row = UIView()
            let circle = UILabel()
            circle.text = "\(index + 1)"
            circle.font = UIFont.boldSystemFont(ofSize: 14)
            circle.textColor = .white
            circle.textAlignment = .center
            circle.backgroundColor = .systemBlue
            circle.layer.cornerRadius = 14
            circle.layer.masksToBounds = true
            circle.translatesAutoresizingMaskIntoConstraints = false
            circle.widthAnchor.constraint(equalToConstant: 28).isActive = true
            circle.heightAnchor.constraint(equalToConstant: 28).isActive = true

            let headingLbl = UILabel()
            headingLbl.text = heading
            headingLbl.font = UIFont.systemFont(ofSize: 15, weight: .semibold)

            let detailLbl = UILabel()
            detailLbl.text = detail
            detailLbl.font = UIFont.systemFont(ofSize: 13)
            detailLbl.textColor = .secondaryLabel
            detailLbl.numberOfLines = 0

            let textStack = UIStackView(arrangedSubviews: [headingLbl, detailLbl])
            textStack.axis = .vertical
            textStack.spacing = 2
            textStack.translatesAutoresizingMaskIntoConstraints = false

            row.addSubview(circle)
            row.addSubview(textStack)

            NSLayoutConstraint.activate([
                circle.topAnchor.constraint(equalTo: row.topAnchor),
                circle.leadingAnchor.constraint(equalTo: row.leadingAnchor),

                textStack.topAnchor.constraint(equalTo: row.topAnchor),
                textStack.leadingAnchor.constraint(equalTo: circle.trailingAnchor, constant: 12),
                textStack.trailingAnchor.constraint(equalTo: row.trailingAnchor),
                textStack.bottomAnchor.constraint(equalTo: row.bottomAnchor),

                row.heightAnchor.constraint(greaterThanOrEqualToConstant: 28),
            ])

            stack.addArrangedSubview(row)
        }
    }
}
