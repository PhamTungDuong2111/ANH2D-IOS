import UIKit

public final class RulerOverlay {
    public var rulerType: RulerType = .none

    // Straight ruler state
    public var straightStart: CGPoint = CGPoint(x: 100, y: 300)
    public var straightEnd: CGPoint = CGPoint(x: 500, y: 300)

    // Circle ruler state
    public var circleCenter: CGPoint = CGPoint(x: 300, y: 300)
    public var circleRadius: CGFloat = 120.0

    // Square ruler state
    public var squareRect: CGRect = CGRect(x: 150, y: 150, width: 300, height: 300)

    public init() {}

    public func snapPoint(_ point: CGPoint) -> CGPoint {
        switch rulerType {
        case .none:
            return point
        case .straight:
            let dx = straightEnd.x - straightStart.x
            let dy = straightEnd.y - straightStart.y
            let lenSq = dx * dx + dy * dy
            if lenSq == 0 { return point }
            let t = max(0.0, min(1.0, ((point.x - straightStart.x) * dx + (point.y - straightStart.y) * dy) / lenSq))
            return CGPoint(x: straightStart.x + t * dx, y: straightStart.y + t * dy)

        case .circle:
            let dx = point.x - circleCenter.x
            let dy = point.y - circleCenter.y
            let dist = sqrt(dx * dx + dy * dy)
            if dist == 0 { return CGPoint(x: circleCenter.x + circleRadius, y: circleCenter.y) }
            let nx = dx / dist
            let ny = dy / dist
            return CGPoint(x: circleCenter.x + nx * circleRadius, y: circleCenter.y + ny * circleRadius)

        case .square:
            let dLeft = abs(point.x - squareRect.minX)
            let dRight = abs(point.x - squareRect.maxX)
            let dTop = abs(point.y - squareRect.minY)
            let dBottom = abs(point.y - squareRect.maxY)
            let minD = min(dLeft, dRight, dTop, dBottom)

            if minD == dLeft {
                return CGPoint(x: squareRect.minX, y: max(squareRect.minY, min(squareRect.maxY, point.y)))
            } else if minD == dRight {
                return CGPoint(x: squareRect.maxX, y: max(squareRect.minY, min(squareRect.maxY, point.y)))
            } else if minD == dTop {
                return CGPoint(x: max(squareRect.minX, min(squareRect.maxX, point.x)), y: squareRect.minY)
            } else {
                return CGPoint(x: max(squareRect.minX, min(squareRect.maxX, point.x)), y: squareRect.maxY)
            }
        }
    }

    public func draw(in context: CGContext) {
        guard rulerType != .none else { return }

        context.saveGState()
        context.setStrokeColor(UIColor.systemOrange.cgColor)
        context.setLineWidth(2.5)
        let dash: [CGFloat] = [10, 6]
        context.setLineDash(phase: 0, lengths: dash)

        switch rulerType {
        case .none:
            break
        case .straight:
            context.move(to: straightStart)
            context.addLine(to: straightEnd)
            context.strokePath()

            // Draw endpoints
            context.setFillColor(UIColor.systemOrange.cgColor)
            context.fillEllipse(in: CGRect(x: straightStart.x - 6, y: straightStart.y - 6, width: 12, height: 12))
            context.fillEllipse(in: CGRect(x: straightEnd.x - 6, y: straightEnd.y - 6, width: 12, height: 12))

        case .circle:
            let rect = CGRect(
                x: circleCenter.x - circleRadius,
                y: circleCenter.y - circleRadius,
                width: circleRadius * 2,
                height: circleRadius * 2
            )
            context.strokeEllipse(in: rect)
            context.setFillColor(UIColor.systemOrange.cgColor)
            context.fillEllipse(in: CGRect(x: circleCenter.x - 4, y: circleCenter.y - 4, width: 8, height: 8))

        case .square:
            context.stroke(squareRect)
            context.setFillColor(UIColor.systemOrange.cgColor)
            let corners = [
                CGPoint(x: squareRect.minX, y: squareRect.minY),
                CGPoint(x: squareRect.maxX, y: squareRect.minY),
                CGPoint(x: squareRect.minX, y: squareRect.maxY),
                CGPoint(x: squareRect.maxX, y: squareRect.maxY)
            ]
            for corner in corners {
                context.fillEllipse(in: CGRect(x: corner.x - 5, y: corner.y - 5, width: 10, height: 10))
            }
        }

        context.restoreGState()
    }
}
