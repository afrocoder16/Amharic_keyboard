import UIKit

/// Screen where the user can paste their Google Cloud Translation API key.
/// The key is stored in the shared App Group UserDefaults so the keyboard
/// extension can read it without rebuilding the app.
final class ApiKeySettingsViewController: UIViewController {

    private let appGroupID  = "group.com.amharickeyboard"
    private let defaultsKey = "google_translate_api_key"

    private let instructionLabel = UILabel()
    private let apiKeyField      = UITextField()
    private let saveButton       = UIButton(type: .system)
    private let statusLabel      = UILabel()
    private let helpButton       = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Translation API Key"
        view.backgroundColor = .systemBackground
        setupUI()
        loadCurrentKey()
    }

    // MARK: - UI Setup

    private func setupUI() {
        // Instruction
        instructionLabel.numberOfLines = 0
        instructionLabel.font = UIFont.systemFont(ofSize: 14)
        instructionLabel.textColor = .secondaryLabel
        instructionLabel.text =
            "The keyboard uses Google Translate for Amharic ↔ English translation.\n\n" +
            "Paste your Google Cloud Translation API key below. The key is stored " +
            "securely in the App Group shared storage — only this app and the " +
            "Amharic keyboard can read it."
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false

        // API key field
        apiKeyField.placeholder = "AIza..."
        apiKeyField.borderStyle = .roundedRect
        apiKeyField.font = UIFont.monospacedSystemFont(ofSize: 14, weight: .regular)
        apiKeyField.autocorrectionType = .no
        apiKeyField.autocapitalizationType = .none
        apiKeyField.clearButtonMode = .whileEditing
        apiKeyField.translatesAutoresizingMaskIntoConstraints = false

        // Save button
        saveButton.setTitle("Save API Key", for: .normal)
        saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        saveButton.backgroundColor = .systemBlue
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 10
        saveButton.heightAnchor.constraint(equalToConstant: 46).isActive = true
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        saveButton.translatesAutoresizingMaskIntoConstraints = false

        // Status label
        statusLabel.font = UIFont.systemFont(ofSize: 13)
        statusLabel.textAlignment = .center
        statusLabel.isHidden = true
        statusLabel.translatesAutoresizingMaskIntoConstraints = false

        // Help button
        helpButton.setTitle("How to get a Google API key →", for: .normal)
        helpButton.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        helpButton.addTarget(self, action: #selector(helpTapped), for: .touchUpInside)
        helpButton.translatesAutoresizingMaskIntoConstraints = false

        // Divider
        let divider = UIView()
        divider.backgroundColor = .separator
        divider.translatesAutoresizingMaskIntoConstraints = false

        let freeLabel = UILabel()
        freeLabel.numberOfLines = 0
        freeLabel.font = UIFont.systemFont(ofSize: 12)
        freeLabel.textColor = .tertiaryLabel
        freeLabel.text = "Google Cloud Translation offers $300 free credit for new accounts, " +
            "covering ~300 million characters — more than enough for personal use."
        freeLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(instructionLabel)
        view.addSubview(apiKeyField)
        view.addSubview(saveButton)
        view.addSubview(statusLabel)
        view.addSubview(helpButton)
        view.addSubview(divider)
        view.addSubview(freeLabel)

        NSLayoutConstraint.activate([
            instructionLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            instructionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            instructionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            apiKeyField.topAnchor.constraint(equalTo: instructionLabel.bottomAnchor, constant: 20),
            apiKeyField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            apiKeyField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            apiKeyField.heightAnchor.constraint(equalToConstant: 44),

            saveButton.topAnchor.constraint(equalTo: apiKeyField.bottomAnchor, constant: 16),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            statusLabel.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 10),
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            divider.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 24),
            divider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            divider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            divider.heightAnchor.constraint(equalToConstant: 0.5),

            helpButton.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 16),
            helpButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            freeLabel.topAnchor.constraint(equalTo: helpButton.bottomAnchor, constant: 16),
            freeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            freeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }

    // MARK: - Logic

    private func loadCurrentKey() {
        let defaults = UserDefaults(suiteName: appGroupID)
        if let key = defaults?.string(forKey: defaultsKey), !key.isEmpty,
           key != "YOUR_GOOGLE_TRANSLATE_API_KEY" {
            // Show masked version
            let masked = String(key.prefix(6)) + "••••••••••••••••••••"
            apiKeyField.placeholder = masked
            statusLabel.text = "✓ API key is saved"
            statusLabel.textColor = .systemGreen
            statusLabel.isHidden = false
        }
    }

    @objc private func saveTapped() {
        guard let key = apiKeyField.text?.trimmingCharacters(in: .whitespaces),
              !key.isEmpty else {
            showStatus("Enter an API key first.", color: .systemOrange)
            return
        }
        guard key.hasPrefix("AIza") else {
            showStatus("Google API keys start with 'AIza...' — check your key.", color: .systemRed)
            return
        }

        let defaults = UserDefaults(suiteName: appGroupID)
        defaults?.set(key, forKey: defaultsKey)
        defaults?.synchronize()

        apiKeyField.text = ""
        let masked = String(key.prefix(6)) + "••••••••••••••••••••"
        apiKeyField.placeholder = masked
        showStatus("✓ Saved! The keyboard will use your key immediately.", color: .systemGreen)
        apiKeyField.resignFirstResponder()
    }

    @objc private func helpTapped() {
        // Open Google Cloud Console
        if let url = URL(string: "https://console.cloud.google.com/apis/credentials") {
            UIApplication.shared.open(url)
        }
    }

    private func showStatus(_ message: String, color: UIColor) {
        statusLabel.text = message
        statusLabel.textColor = color
        statusLabel.isHidden = false
    }
}
