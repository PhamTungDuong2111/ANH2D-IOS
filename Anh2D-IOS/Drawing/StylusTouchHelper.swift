import UIKit

public final class StylusTouchHelper {
    public var isStylusOnlyMode: Bool = false
    public var isPressureEnabled: Bool = true

    public var lastPressure: CGFloat = 1.0
    public var lastAltitude: CGFloat = 0.0 // Tilt angle
    public var isStylusActive: Bool = false

    public init(isStylusOnlyMode: Bool = false, isPressureEnabled: Bool = true) {
        self.isStylusOnlyMode = isStylusOnlyMode
        self.isPressureEnabled = isPressureEnabled
    }

    public func processTouch(_ touch: UITouch) -> Bool {
        isStylusActive = (touch.type == .pencil)

        if isStylusOnlyMode && !isStylusActive {
            // Reject finger touch when stylus-only (palm rejection) mode is enabled
            return false
        }

        if isPressureEnabled && isStylusActive && touch.maximumPossibleForce > 0 {
            let normalizedForce = touch.force / touch.maximumPossibleForce
            // Scale pressure curve between 0.2 and 1.8
            lastPressure = max(0.2, min(1.8, normalizedForce * 1.5))
        } else {
            lastPressure = 1.0
        }

        lastAltitude = touch.altitudeAngle
        return true
    }

    public func calculateStrokeWidth(baseWidth: CGFloat) -> CGFloat {
        if !isPressureEnabled || !isStylusActive {
            return baseWidth
        }
        // Pressure dynamically modulates stroke width from 30% to 180%
        return max(1.0, baseWidth * (0.3 + lastPressure * 0.9))
    }
}
