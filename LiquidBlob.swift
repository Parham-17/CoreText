import SwiftUI

/// Smooth, morphing blob.
/// `phase` drives how "squished" it is.
struct LiquidBlob: Shape {
    var phase: CGFloat

    var animatableData: CGFloat {
        get { phase }
        set { phase = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let radius = min(rect.width, rect.height) / 2
        let center = CGPoint(x: rect.midX, y: rect.midY)

        // Fewer points + stronger noise => more visible deformation
        let pointsCount = 20
        var points: [CGPoint] = []

        for i in 0..<pointsCount {
            let t = CGFloat(i) / CGFloat(pointsCount)
            let angle = t * .pi * 2

            // Two smooth waves added together
            let noise1 = 0.10 * sin(phase + angle * 1.1)
            let noise2 = 0.06 * sin(phase * 0.6 + angle * 2.4)
            let r = radius * (0.88 + noise1 + noise2)   // 0.72R–1.0R approx.

            let x = center.x + cos(angle) * r
            let y = center.y + sin(angle) * r
            points.append(CGPoint(x: x, y: y))
        }

        var path = Path()
        guard !points.isEmpty else { return path }

        path.move(to: points[0])

        // Catmull–Rom style cubic curve through all points → no sharp corners
        let n = pointsCount
        for i in 0..<n {
            let p0 = points[(i - 1 + n) % n]
            let p1 = points[i]
            let p2 = points[(i + 1) % n]
            let p3 = points[(i + 2) % n]

            let m1 = CGPoint(
                x: p1.x + (p2.x - p0.x) / 6,
                y: p1.y + (p2.y - p0.y) / 6
            )
            let m2 = CGPoint(
                x: p2.x - (p3.x - p1.x) / 6,
                y: p2.y - (p3.y - p1.y) / 6
            )

            path.addCurve(to: p2, control1: m1, control2: m2)
        }

        path.closeSubpath()
        return path
    }
}
