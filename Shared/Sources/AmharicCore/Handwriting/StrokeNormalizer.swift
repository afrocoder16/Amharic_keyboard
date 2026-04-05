import Foundation
import CoreGraphics

/// Pre-processes raw touch strokes for the $N recognizer.
/// Each stroke is a sequence of CGPoints collected during a touch event.
public enum StrokeNormalizer {

    /// Number of equidistant points each stroke is resampled to.
    public static let resampleCount = 64

    /// Normalize a set of strokes:
    ///   1. Resample each stroke to `resampleCount` equidistant points.
    ///   2. Translate the combined bounding box so its origin is (0, 0).
    ///   3. Scale so the bounding box fits in a 1×1 unit square (aspect-ratio preserving).
    public static func normalize(_ strokes: [[CGPoint]]) -> [[CGPoint]] {
        guard !strokes.isEmpty else { return [] }

        let resampled = strokes.map { resample($0, count: resampleCount) }
        let all = resampled.flatMap { $0 }

        guard !all.isEmpty else { return [] }

        let minX = all.map(\.x).min()!
        let minY = all.map(\.y).min()!
        let maxX = all.map(\.x).max()!
        let maxY = all.map(\.y).max()!
        let width  = max(maxX - minX, 1e-6)
        let height = max(maxY - minY, 1e-6)
        let scale  = 1.0 / max(width, height)

        return resampled.map { stroke in
            stroke.map { pt in
                CGPoint(x: (pt.x - minX) * scale, y: (pt.y - minY) * scale)
            }
        }
    }

    // MARK: - Private

    /// Resample `points` to exactly `count` equidistant points using linear interpolation.
    private static func resample(_ points: [CGPoint], count: Int) -> [CGPoint] {
        guard points.count > 1 else {
            return Array(repeating: points.first ?? .zero, count: count)
        }

        let totalLength = pathLength(points)
        let interval = totalLength / Double(count - 1)
        var result: [CGPoint] = [points[0]]
        var accumulated: Double = 0
        var i = 1

        while result.count < count && i < points.count {
            let d = distance(points[i - 1], points[i])
            if accumulated + d >= interval {
                let t = (interval - accumulated) / d
                let x = points[i - 1].x + t * (points[i].x - points[i - 1].x)
                let y = points[i - 1].y + t * (points[i].y - points[i - 1].y)
                let newPt = CGPoint(x: x, y: y)
                result.append(newPt)
                accumulated = 0
                // Don't advance i — continue from newPt toward points[i]
                // We mimic this by inserting newPt as the new "previous" point
                // by not advancing i but subtracting the used portion.
                accumulated -= interval
            } else {
                accumulated += d
                i += 1
            }
        }

        // Fill remaining points with the last point if needed
        while result.count < count {
            result.append(points.last!)
        }
        return Array(result.prefix(count))
    }

    private static func pathLength(_ points: [CGPoint]) -> Double {
        zip(points, points.dropFirst()).reduce(0.0) { acc, pair in
            acc + distance(pair.0, pair.1)
        }
    }

    private static func distance(_ a: CGPoint, _ b: CGPoint) -> Double {
        let dx = a.x - b.x
        let dy = a.y - b.y
        return sqrt(dx * dx + dy * dy)
    }
}
