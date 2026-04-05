import UIKit

/// Guides the user to enable the Amharic keyboard in iOS Settings.
final class OnboardingViewController: UIViewController {

    private let scrollView  = UIScrollView()
    private let stackView   = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Amharic Keyboard"
        view.backgroundColor = .systemBackground
        setupUI()
    }

    private func setupUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .fill
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 30, leading: 24, bottom: 30, trailing: 24)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])

        // Header
        let header = makeLabel("ⴀ Amharic Keyboard", style: .title1, weight: .bold)
        let subtitle = makeLabel("Type Amharic (ግዕዝ) in any app on your iPhone.", style: .body)
        subtitle.textColor = .secondaryLabel

        // Step cards
        let step1 = makeStepCard(
            number: "1",
            title: "Open Settings",
            detail: "Tap the button below to open iPhone Settings.",
            imageName: "gear"
        )
        let step2 = makeStepCard(
            number: "2",
            title: "General → Keyboard → Keyboards",
            detail: "Tap \"Add New Keyboard…\" and select Amharic.",
            imageName: "keyboard"
        )
        let step3 = makeStepCard(
            number: "3",
            title: "Allow Full Access (Optional)",
            detail: "Enable \"Allow Full Access\" to use the translation feature. Your input is never stored or shared.",
            imageName: "globe"
        )
        let step4 = makeStepCard(
            number: "4",
            title: "Switch to Amharic",
            detail: "In any text field, tap the 🌐 globe key on the keyboard to switch to Amharic.",
            imageName: "textformat"
        )

        // Settings button
        let settingsBtn = UIButton(type: .system)
        settingsBtn.setTitle("Open Settings", for: .normal)
        settingsBtn.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        settingsBtn.backgroundColor = .systemBlue
        settingsBtn.setTitleColor(.white, for: .normal)
        settingsBtn.layer.cornerRadius = 12
        settingsBtn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        settingsBtn.addTarget(self, action: #selector(openSettings), for: .touchUpInside)

        // Test field
        let testLabel = makeLabel("Try it here:", style: .headline)
        let testField = UITextField()
        testField.placeholder = "Tap to test your Amharic keyboard…"
        testField.borderStyle = .roundedRect
        testField.font = UIFont.systemFont(ofSize: 16)
        testField.heightAnchor.constraint(equalToConstant: 44).isActive = true

        [header, subtitle, step1, step2, step3, step4, settingsBtn, testLabel, testField].forEach {
            stackView.addArrangedSubview($0)
        }
    }

    @objc private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    // MARK: - Helpers

    private func makeLabel(_ text: String, style: UIFont.TextStyle, weight: UIFont.Weight = .regular) -> UILabel {
        let lbl = UILabel()
        lbl.text = text
        lbl.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: style).pointSize, weight: weight)
        lbl.numberOfLines = 0
        return lbl
    }

    private func makeStepCard(number: String, title: String, detail: String, imageName: String) -> UIView {
        let card = UIView()
        card.backgroundColor = .secondarySystemBackground
        card.layer.cornerRadius = 12

        let numLabel = UILabel()
        numLabel.text = number
        numLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        numLabel.textColor = .systemBlue
        numLabel.translatesAutoresizingMaskIntoConstraints = false

        let icon = UIImageView(image: UIImage(systemName: imageName))
        icon.tintColor = .systemBlue
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false

        let titleLbl = makeLabel(title, style: .headline, weight: .semibold)
        titleLbl.translatesAutoresizingMaskIntoConstraints = false

        let detailLbl = makeLabel(detail, style: .subheadline)
        detailLbl.textColor = .secondaryLabel
        detailLbl.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(numLabel)
        card.addSubview(icon)
        card.addSubview(titleLbl)
        card.addSubview(detailLbl)

        NSLayoutConstraint.activate([
            numLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            numLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            numLabel.widthAnchor.constraint(equalToConstant: 24),

            icon.centerYAnchor.constraint(equalTo: numLabel.centerYAnchor),
            icon.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            icon.widthAnchor.constraint(equalToConstant: 24),
            icon.heightAnchor.constraint(equalToConstant: 24),

            titleLbl.topAnchor.constraint(equalTo: numLabel.bottomAnchor, constant: 6),
            titleLbl.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            titleLbl.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),

            detailLbl.topAnchor.constraint(equalTo: titleLbl.bottomAnchor, constant: 4),
            detailLbl.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            detailLbl.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            detailLbl.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14),
        ])

        return card
    }
}
