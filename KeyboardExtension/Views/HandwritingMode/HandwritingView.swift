import UIKit
import AmharicCore

protocol HandwritingViewDelegate: AnyObject {
    func handwritingView(_ view: HandwritingView, didSelectCharacter character: Character)
}

/// Container view for the handwriting input mode.
/// Layout: candidate bar (top) + drawing canvas + clear button.
final class HandwritingView: UIView {

    weak var delegate: HandwritingViewDelegate?

    private let candidateBar = CandidateBarView()
    private let canvas       = StrokeCanvasView()
    private let clearButton  = UIButton(type: .system)
    private let recognizer   = StrokeRecognizer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Public

    func clearAll() {
        canvas.clearCanvas()
        candidateBar.clearCandidates()
    }

    // MARK: - Setup

    private func setup() {
        backgroundColor = KeyboardTheme.background

        candidateBar.delegate = self
        canvas.delegate = self

        clearButton.setTitle("Clear", for: .normal)
        clearButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        clearButton.setTitleColor(.systemBlue, for: .normal)
        clearButton.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)

        [candidateBar, canvas, clearButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }

        NSLayoutConstraint.activate([
            candidateBar.topAnchor.constraint(equalTo: topAnchor),
            candidateBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            candidateBar.trailingAnchor.constraint(equalTo: trailingAnchor),
            candidateBar.heightAnchor.constraint(equalToConstant: KeyboardTheme.suggestionBarHeight),

            clearButton.topAnchor.constraint(equalTo: candidateBar.bottomAnchor, constant: 4),
            clearButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            clearButton.heightAnchor.constraint(equalToConstant: 24),

            canvas.topAnchor.constraint(equalTo: clearButton.bottomAnchor, constant: 4),
            canvas.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            canvas.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            canvas.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
        ])
    }

    @objc private func clearTapped() {
        clearAll()
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
        delegate?.handwritingView(self, didSelectCharacter: character)
        clearAll()
    }
}
