import Foundation
import CoreGraphics

/// Recognizes handwritten Ethiopic characters using the $N multi-stroke recognizer algorithm.
///
/// Reference: Wobbrock et al. "$N-Protractor: A fast and accurate multistroke recognizer"
///
/// Templates are loaded from `ethiopic_strokes.json` bundled with the package.
/// Each entry describes a character with one or more reference stroke sequences.
public final class StrokeRecognizer {

    // MARK: - Template Model

    private struct Template {
        let character: Character
        let strokes: [[CGPoint]]   // already normalized
    }

    // MARK: - State

    private var templates: [Template] = []

    public init() {
        loadTemplates()
    }

    // MARK: - Public API

    /// Recognize `strokes` and return up to `topK` candidates sorted by confidence (desc).
    public func recognize(_ strokes: [[CGPoint]], topK: Int = 5) -> [HandwritingCandidate] {
        guard !strokes.isEmpty, !templates.isEmpty else { return [] }

        let normalized = StrokeNormalizer.normalize(strokes)
        let flat = normalized.flatMap { $0 }

        var scores: [(character: Character, score: Double)] = []

        for template in templates {
            let templateFlat = template.strokes.flatMap { $0 }
            let score = protractorDistance(flat, templateFlat)
            scores.append((template.character, score))
        }

        // Lower distance = better match; convert to confidence in [0,1]
        let maxScore = scores.map(\.score).max() ?? 1
        let candidates = scores
            .sorted { $0.score < $1.score }
            .prefix(topK)
            .map { HandwritingCandidate(character: $0.character, confidence: 1.0 - ($0.score / maxScore)) }

        return Array(candidates)
    }

    // MARK: - Protractor Distance

    /// Computes the Protractor-style golden section distance between two point sequences.
    /// Both sequences should already be normalized to the same length.
    private func protractorDistance(_ a: [CGPoint], _ b: [CGPoint]) -> Double {
        let len = min(a.count, b.count)
        guard len > 0 else { return Double.infinity }

        var num: Double = 0
        var den: Double = 0

        for i in 0..<len {
            num += a[i].x * b[i].x + a[i].y * b[i].y
            den += a[i].x * a[i].x + a[i].y * a[i].y
        }

        guard den > 0 else { return Double.infinity }
        return acos(max(-1, min(1, num / sqrt(den * den))))
    }

    // MARK: - Template Loading

    private func loadTemplates() {
        guard let url = Bundle.module.url(forResource: "ethiopic_strokes", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let json = try? JSONDecoder().decode(StrokeTemplateFile.self, from: data) else {
            loadBuiltInTemplates()
            return
        }

        templates = json.templates.compactMap { entry in
            guard let char = entry.character.first else { return nil }
            let pointStrokes: [[CGPoint]] = entry.strokes.map { stroke in
                stride(from: 0, to: stroke.count - 1, by: 2).map { i in
                    CGPoint(x: stroke[i], y: stroke[i + 1])
                }
            }
            let normalized = StrokeNormalizer.normalize(pointStrokes)
            return Template(character: char, strokes: normalized)
        }
    }

    /// Minimal built-in templates so the recognizer works out of the box.
    private func loadBuiltInTemplates() {
        // These are intentionally minimal placeholder templates.
        // Replace with real stroke data via ethiopic_strokes.json.
        let placeholders: [(String, [[Double]])] = [
            ("ሀ", [[0.1, 0.5, 0.5, 0.5, 0.9, 0.5]]),
            ("ለ", [[0.5, 0.1, 0.5, 0.9]]),
            ("መ", [[0.1, 0.3, 0.9, 0.3, 0.5, 0.3, 0.5, 0.9]]),
            ("ሰ", [[0.1, 0.5, 0.9, 0.5]]),
            ("ቤ", [[0.2, 0.1, 0.2, 0.9], [0.2, 0.5, 0.8, 0.5]]),
        ]
        templates = placeholders.compactMap { (charStr, rawStrokes) in
            guard let char = charStr.first else { return nil }
            let pointStrokes: [[CGPoint]] = rawStrokes.map { flat in
                stride(from: 0, to: flat.count - 1, by: 2).map { i in
                    CGPoint(x: flat[i], y: flat[i + 1])
                }
            }
            let normalized = StrokeNormalizer.normalize(pointStrokes)
            return Template(character: char, strokes: normalized)
        }
    }
}

// MARK: - JSON Models

private struct StrokeTemplateFile: Decodable {
    let templates: [StrokeEntry]
}

private struct StrokeEntry: Decodable {
    let character: String
    /// Each stroke is a flat array of [x, y, x, y, ...] normalized doubles.
    let strokes: [[Double]]
}
