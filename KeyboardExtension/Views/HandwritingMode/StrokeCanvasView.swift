import UIKit

protocol StrokeCanvasDelegate: AnyObject {
    func strokeCanvas(_ canvas: StrokeCanvasView, didFinishStrokes strokes: [[CGPoint]])
}

/// A drawing canvas that captures multi-stroke input and triggers recognition
/// 1.2 seconds after the user lifts their finger.
final class StrokeCanvasView: UIView {

    weak var delegate: StrokeCanvasDelegate?

    private var strokes: [[CGPoint]] = []
    private var currentStroke: [CGPoint] = []
    private let shapeLayer = CAShapeLayer()
    private let path = UIBezierPath()
    private var recognitionTimer: Timer?
    private let recognitionDelay: TimeInterval = 1.2

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Public

    func clearCanvas() {
        strokes.removeAll()
        currentStroke.removeAll()
        path.removeAllPoints()
        shapeLayer.path = nil
        recognitionTimer?.invalidate()
    }

    // MARK: - Setup

    private func setup() {
        backgroundColor = KeyboardTheme.canvasBackground
        layer.cornerRadius = 8
        isMultipleTouchEnabled = false

        shapeLayer.strokeColor = KeyboardTheme.strokeColor.cgColor
        shapeLayer.lineWidth   = 3.0
        shapeLayer.fillColor   = UIColor.clear.cgColor
        shapeLayer.lineCap     = .round
        shapeLayer.lineJoin    = .round
        layer.addSublayer(shapeLayer)

        // Placeholder text
        let hint = UILabel()
        hint.text = "Draw here"
        hint.textColor = UIColor.tertiaryLabel
        hint.font = UIFont.systemFont(ofSize: 18, weight: .light)
        hint.tag = 99
        hint.translatesAutoresizingMaskIntoConstraints = false
        addSubview(hint)
        NSLayoutConstraint.activate([
            hint.centerXAnchor.constraint(equalTo: centerXAnchor),
            hint.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        shapeLayer.frame = bounds
    }

    // MARK: - Touch Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let pt = touches.first?.location(in: self) else { return }
        // Hide placeholder
        viewWithTag(99)?.isHidden = true
        recognitionTimer?.invalidate()
        currentStroke = [pt]
        path.move(to: pt)
        shapeLayer.path = path.cgPath
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let pt = touches.first?.location(in: self) else { return }
        currentStroke.append(pt)
        path.addLine(to: pt)
        shapeLayer.path = path.cgPath
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let pt = touches.first?.location(in: self) else { return }
        currentStroke.append(pt)
        if currentStroke.count > 1 {
            strokes.append(currentStroke)
        }
        currentStroke = []
        scheduleRecognition()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }

    // MARK: - Recognition Timer

    private func scheduleRecognition() {
        recognitionTimer?.invalidate()
        recognitionTimer = Timer.scheduledTimer(withTimeInterval: recognitionDelay, repeats: false) { [weak self] _ in
            guard let self = self, !self.strokes.isEmpty else { return }
            self.delegate?.strokeCanvas(self, didFinishStrokes: self.strokes)
        }
    }
}
