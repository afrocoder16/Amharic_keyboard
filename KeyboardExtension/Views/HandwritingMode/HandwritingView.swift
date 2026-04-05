import UIKit
import AmharicCore

protocol HandwritingViewDelegate: AnyObject {
    /// Called when user taps a recognized character candidate.
    /// The character is added to the word accumulation buffer — NOT inserted directly.
    func handwritingView(_ view: HandwritingView, didSelectCharacter character: Character)
    /// Called when user taps the Space/Commit button — flush the buffer as a word.
    func handwritingViewDidTapSpace(_ view: HandwritingView)
}

/// Container view for the handwriting input mode.
///
/// UX Flow (matches the Google Translate keyboard screenshots):
///   1. User draws a character on the large canvas.
///   2. After 1.2s idle, the top-5 recognized candidates appear in the candidate bar.
///   3. User taps a candidate → character is added to an accumulation buffer.
///   4. The suggestion bar (in RootKeyboardView) shows word completions for the buffer.
///   5. User can:
///      a) Tap a word suggestion → buffer is replaced with the full word + space.
///      b) Keep drawing → next character is appended to the buffer.
///      c) Tap "Space" below the canvas → buffer is committed as a word + space.
///      d) Tap "Clear" → canvas cleared, buffer unchanged (for re-drawing a stroke).
///
/// The word accumulation buffer lives in RootKeyboardView so the suggestion bar
/// (which is outside HandwritingView) can also act on it.
final class HandwritingView: UIView {

    weak var delegate: HandwritingViewDelegate?

    /// Shows the current word being built from handwriting strokes.
    /// Updated by RootKeyboardView when characters are added to the buffer.
    var currentWordPreview: String = "" {
        didSet { wordPreviewLabel.text = currentWordPreview.isEmpty ? "" : "Building: \(currentWordPreview)" }
    }

    private let candidateBar    = CandidateBarView()
    private let canvas          = StrokeCanvasView()
    private let bottomBar       = UIView()
    private let clearButton     = UIButton(type: .system)
    private let spaceButton     = UIButton(type: .system)
    private let wordPreviewLabel = UILabel()
    private let recognizer      = StrokeRecognizer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Public

    func clearCanvas() {
        canvas.clearCanvas()
        candidateBar.clearCandidates()
    }

    // MARK: - Setup

    private func setup() {
        backgroundColor = KeyboardTheme.background

        candidateBar.delegate = self
        canvas.delegate = self

        // Word preview label — shows what word is being built
        wordPreviewLabel.font = UIFont.systemFont(ofSize: 13)
        wordPreviewLabel.textColor = UIColor.secondaryLabel
        wordPreviewLabel.textAlignment = .center

        // Bottom action bar
        bottomBar.backgroundColor = KeyboardTheme.specialKeyBackground.withAlphaComponent(0.6)

        clearButton.setTitle("Clear", for: .normal)
        clearButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        clearButton.setTitleColor(.systemBlue, for: .normal)
        clearButton.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)

        var spaceConfig = UIButton.Configuration.filled()
        spaceConfig.title = "Space  →  Insert Word"
        spaceConfig.baseForegroundColor = .white
        spaceConfig.baseBackgroundColor = .systemBlue
        spaceConfig.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16)
        spaceButton.configuration = spaceConfig
        spaceButton.layer.cornerRadius = 8
        spaceButton.addTarget(self, action: #selector(spaceTapped), for: .touchUpInside)

        let bottomStack = UIStackView(arrangedSubviews: [clearButton, UIView(), spaceButton])
        bottomStack.axis = .horizontal
        bottomStack.alignment = .center
        bottomStack.translatesAutoresizingMaskIntoConstraints = false
        bottomBar.addSubview(bottomStack)

        NSLayoutConstraint.activate([
            bottomStack.topAnchor.constraint(equalTo: bottomBar.topAnchor, constant: 6),
            bottomStack.bottomAnchor.constraint(equalTo: bottomBar.bottomAnchor, constant: -6),
            bottomStack.leadingAnchor.constraint(equalTo: bottomBar.leadingAnchor, constant: 12),
            bottomStack.trailingAnchor.constraint(equalTo: bottomBar.trailingAnchor, constant: -12),
        ])

        [candidateBar, wordPreviewLabel, canvas, bottomBar].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }

        NSLayoutConstraint.activate([
            // Candidate bar at top — shows top-5 recognized characters after drawing
            candidateBar.topAnchor.constraint(equalTo: topAnchor),
            candidateBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            candidateBar.trailingAnchor.constraint(equalTo: trailingAnchor),
            candidateBar.heightAnchor.constraint(equalToConstant: KeyboardTheme.suggestionBarHeight),

            // Word preview below candidates
            wordPreviewLabel.topAnchor.constraint(equalTo: candidateBar.bottomAnchor, constant: 2),
            wordPreviewLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            wordPreviewLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            wordPreviewLabel.heightAnchor.constraint(equalToConstant: 18),

            // Bottom bar with Clear + Space buttons
            bottomBar.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomBar.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomBar.heightAnchor.constraint(equalToConstant: 44),

            // Drawing canvas takes the remaining space
            canvas.topAnchor.constraint(equalTo: wordPreviewLabel.bottomAnchor, constant: 4),
            canvas.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            canvas.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            canvas.bottomAnchor.constraint(equalTo: bottomBar.topAnchor, constant: -4),
        ])
    }

    @objc private func clearTapped() {
        // Only clear the canvas — the accumulated word buffer is NOT cleared.
        // This lets users re-draw a stroke if recognition was wrong.
        clearCanvas()
    }

    @objc private func spaceTapped() {
        clearCanvas()
        delegate?.handwritingViewDidTapSpace(self)
    }
}

// MARK: - StrokeCanvasDelegate

extension HandwritingView: StrokeCanvasDelegate {
    func strokeCanvas(_ canvas: StrokeCanvasView, didFinishStrokes strokes: [[CGPoint]]) {
        let candidates = recognizer.recognize(strokes, topK: 5)
        candidateBar.update(candidates: candidates)
    }
}

// MARK: - CandidateBarDelegate

extension HandwritingView: CandidateBarDelegate {
    func candidateBar(_ bar: CandidateBarView, didSelectCandidate character: Character) {
        // Tell the delegate (RootKeyboardView) to append to the word buffer.
        // Clear the canvas so the user can draw the next character.
        delegate?.handwritingView(self, didSelectCharacter: character)
        clearCanvas()
    }
}
