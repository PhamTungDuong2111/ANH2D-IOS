import UIKit

public final class LassoManager {
    public var points: [CGPoint] = []
    public var isSelecting: Bool = false
    public var hasSelection: Bool = false

    public var selectedImage: UIImage?
    public var selectionBounds: CGRect = .zero
    public var currentOffset: CGPoint = .zero
    public var isFlippedHorizontal: Bool = false
    public var isFlippedVertical: Bool = false

    public init() {}

    public func startSelection(at point: CGPoint) {
        points = [point]
        isSelecting = true
        hasSelection = false
        selectedImage = nil
        selectionBounds = .zero
        currentOffset = .zero
        isFlippedHorizontal = false
        isFlippedVertical = false
    }

    public func addPoint(_ point: CGPoint) {
        guard isSelecting else { return }
        points.append(point)
    }

    public func finishSelection(sourceImage: UIImage?) -> Bool {
        guard points.count >= 3, let source = sourceImage else {
            cancelSelection()
            return false
        }
        isSelecting = false

        // Compute bounding box
        var minX = points[0].x, maxX = points[0].x
        var minY = points[0].y, maxY = points[0].y
        for p in points {
            minX = min(minX, p.x)
            maxX = max(maxX, p.x)
            minY = min(minY, p.y)
            maxY = max(maxY, p.y)
        }

        let bounds = CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
        guard bounds.width > 5 && bounds.height > 5 else {
            cancelSelection()
            return false
        }

        selectionBounds = bounds

        // Crop selected region masked by lasso polygon
        let renderer = UIGraphicsImageRenderer(size: bounds.size)
        selectedImage = renderer.image { context in
            let cg = context.cgContext
            let path = CGMutablePath()
            let first = CGPoint(x: points[0].x - bounds.minX, y: points[0].y - bounds.minY)
            path.move(to: first)
            for i in 1..<points.count {
                let pt = CGPoint(x: points[i].x - bounds.minX, y: points[i].y - bounds.minY)
                path.addLine(to: pt)
            }
            path.closeSubpath()

            cg.addPath(path)
            cg.clip()

            source.draw(in: CGRect(
                x: -bounds.minX,
                y: -bounds.minY,
                width: source.size.width,
                height: source.size.height
            ))
        }

        hasSelection = (selectedImage != nil)
        return hasSelection
    }

    public func flipHorizontal() {
        guard let img = selectedImage else { return }
        isFlippedHorizontal.toggle()
        selectedImage = img.withHorizontallyFlippedOrientation()
    }

    public func flipVertical() {
        guard let img = selectedImage, let cg = img.cgImage else { return }
        isFlippedVertical.toggle()
        let renderer = UIGraphicsImageRenderer(size: img.size)
        selectedImage = renderer.image { context in
            let cgContext = context.cgContext
            cgContext.translateBy(x: 0, y: img.size.height)
            cgContext.scaleBy(x: 1.0, y: -1.0)
            cgContext.draw(cg, in: CGRect(origin: .zero, size: img.size))
        }
    }

    public func commitSelection(onto sourceImage: UIImage?, canvasSize: CGSize) -> UIImage {
        guard hasSelection, let selected = selectedImage else {
            return sourceImage ?? UIImage.createBlank(size: canvasSize)
        }

        let renderer = UIGraphicsImageRenderer(size: canvasSize)
        let result = renderer.image { _ in
            sourceImage?.draw(in: CGRect(origin: .zero, size: canvasSize))

            let destRect = CGRect(
                x: selectionBounds.minX + currentOffset.x,
                y: selectionBounds.minY + currentOffset.y,
                width: selectionBounds.width,
                height: selectionBounds.height
            )
            selected.draw(in: destRect)
        }

        cancelSelection()
        return result
    }

    public func cancelSelection() {
        points.removeAll()
        isSelecting = false
        hasSelection = false
        selectedImage = nil
        selectionBounds = .zero
        currentOffset = .zero
    }

    public func drawOverlay(in context: CGContext) {
        context.saveGState()

        if isSelecting && points.count > 1 {
            context.setStrokeColor(UIColor.systemCyan.cgColor)
            context.setLineWidth(2.0)
            let dash: [CGFloat] = [6, 4]
            context.setLineDash(phase: 0, lengths: dash)

            context.move(to: points[0])
            for i in 1..<points.count {
                context.addLine(to: points[i])
            }
            context.strokePath()
        }

        if hasSelection {
            let targetRect = CGRect(
                x: selectionBounds.minX + currentOffset.x,
                y: selectionBounds.minY + currentOffset.y,
                width: selectionBounds.width,
                height: selectionBounds.height
            )

            // Draw animated dashed selection rectangle
            context.setStrokeColor(UIColor.systemCyan.cgColor)
            context.setLineWidth(2.0)
            let dash: [CGFloat] = [8, 4]
            context.setLineDash(phase: 0, lengths: dash)
            context.stroke(targetRect)

            // Draw corner control handles
            context.setFillColor(UIColor.systemCyan.cgColor)
            let handleRadius: CGFloat = 5.0
            let corners = [
                CGPoint(x: targetRect.minX, y: targetRect.minY),
                CGPoint(x: targetRect.maxX, y: targetRect.minY),
                CGPoint(x: targetRect.minX, y: targetRect.maxY),
                CGPoint(x: targetRect.maxX, y: targetRect.maxY)
            ]
            for corner in corners {
                context.fillEllipse(in: CGRect(
                    x: corner.x - handleRadius,
                    y: corner.y - handleRadius,
                    width: handleRadius * 2,
                    height: handleRadius * 2
                ))
            }
        }

        context.restoreGState()
    }
}
