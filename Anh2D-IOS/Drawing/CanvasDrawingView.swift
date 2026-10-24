import UIKit
import SwiftUI

public final class CanvasDrawingView: UIView {
    public var project: Project {
        didSet {
            setNeedsDisplay()
        }
    }

    // Active tool state
    public var currentTool: ToolType = .pen
    public var currentShape: ShapeType = .line
    public var brushColor: UIColor = .black
    public var brushSize: CGFloat = 10.0
    public var brushOpacity: CGFloat = 1.0

    // Apple Pencil / Stylus helper
    public let stylusHelper = StylusTouchHelper()

    // Lasso and Ruler
    public let lassoManager = LassoManager()
    public let rulerOverlay = RulerOverlay()
    public var isGridVisible: Bool = false

    // Onion Skin
    public var isOnionSkinEnabled: Bool = true
    public var onionSkinFramesBefore: Int = 1
    public var onionSkinFramesAfter: Int = 1
    public var onionSkinAlpha: CGFloat = 0.35

    // Pan & Zoom
    public var scaleFactor: CGFloat = 1.0
    public var panOffset: CGPoint = .zero
    public var isPanZoomActive: Bool = false

    // Undo / Redo stacks for the active layer
    private var undoStack: [UIImage] = []
    private var redoStack: [UIImage] = []
    private let maxHistory = 25

    // In-progress drawing path
    private var activePoints: [CGPoint] = []
    private var shapeStart: CGPoint = .zero
    private var shapeCurrent: CGPoint = .zero
    private var isDrawing: Bool = false

    public var onProjectChanged: (() -> Void)?

    public init(project: Project) {
        self.project = project
        super.init(frame: .zero)
        backgroundColor = .clear
        isMultipleTouchEnabled = true
        setupGestures()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupGestures() {
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        pinch.cancelsTouchesInView = false
        addGestureRecognizer(pinch)

        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        pan.minimumNumberOfTouches = 2
        pan.maximumNumberOfTouches = 2
        pan.cancelsTouchesInView = false
        addGestureRecognizer(pan)
    }

    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        if gesture.state == .began || gesture.state == .changed {
            let scale = gesture.scale
            scaleFactor = max(0.2, min(10.0, scaleFactor * scale))
            gesture.scale = 1.0
            setNeedsDisplay()
        }
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        if gesture.state == .changed {
            let translation = gesture.translation(in: self)
            panOffset.x += translation.x
            panOffset.y += translation.y
            gesture.setTranslation(.zero, in: self)
            setNeedsDisplay()
        }
    }

    public func resetViewport() {
        let padding: CGFloat = 40.0
        let availableW = bounds.width - padding * 2
        let availableH = bounds.height - padding * 2
        guard availableW > 0, availableH > 0, project.width > 0, project.height > 0 else { return }

        let scaleW = availableW / CGFloat(project.width)
        let scaleH = availableH / CGFloat(project.height)
        scaleFactor = max(0.1, min(scaleW, scaleH))

        panOffset.x = (bounds.width - CGFloat(project.width) * scaleFactor) / 2.0
        panOffset.y = (bounds.height - CGFloat(project.height) * scaleFactor) / 2.0
        setNeedsDisplay()
    }

    public func screenToCanvas(_ screenPoint: CGPoint) -> CGPoint {
        CGPoint(
            x: (screenPoint.x - panOffset.x) / scaleFactor,
            y: (screenPoint.y - panOffset.y) / scaleFactor
        )
    }

    // MARK: - Undo / Redo
    public func saveUndoSnapshot() {
        guard let layer = project.activeLayer, let frame = project.currentFrame else { return }
        let currentImg = frame.getImage(for: layer.id) ?? UIImage.createBlank(size: project.canvasSize)
        undoStack.append(currentImg)
        if undoStack.count > maxHistory {
            undoStack.removeFirst()
        }
        redoStack.removeAll()
    }

    public func undo() {
        guard !undoStack.isEmpty, let layer = project.activeLayer, let frame = project.currentFrame else { return }
        let currentImg = frame.getImage(for: layer.id) ?? UIImage.createBlank(size: project.canvasSize)
        redoStack.append(currentImg)

        let prev = undoStack.removeLast()
        frame.setImage(prev, for: layer.id)
        setNeedsDisplay()
        onProjectChanged?()
    }

    public func redo() {
        guard !redoStack.isEmpty, let layer = project.activeLayer, let frame = project.currentFrame else { return }
        let currentImg = frame.getImage(for: layer.id) ?? UIImage.createBlank(size: project.canvasSize)
        undoStack.append(currentImg)

        let next = redoStack.removeLast()
        frame.setImage(next, for: layer.id)
        setNeedsDisplay()
        onProjectChanged?()
    }

    public var canUndo: Bool { !undoStack.isEmpty }
    public var canRedo: Bool { !redoStack.isEmpty }

    // MARK: - Touch Handling
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        if touches.count > 1 || event?.allTouches?.count ?? 0 > 1 {
            isDrawing = false
            return
        }

        stylusHelper.isStylusOnlyMode = project.stylusOnlyMode
        if !stylusHelper.processTouch(touch) {
            return // Rejected palm touch
        }

        let loc = touch.location(in: self)
        var canvasPt = screenToCanvas(loc)
        canvasPt = rulerOverlay.snapPoint(canvasPt)

        if currentTool == .lasso {
            if lassoManager.hasSelection {
                // If user taps outside, commit selection
                commitLasso()
            } else {
                lassoManager.startSelection(at: canvasPt)
                setNeedsDisplay()
            }
            return
        }

        if currentTool == .eyedropper {
            sampleColor(at: canvasPt)
            return
        }

        if currentTool == .bucket {
            applyFloodFill(at: canvasPt)
            return
        }

        saveUndoSnapshot()
        isDrawing = true
        activePoints = [canvasPt]
        shapeStart = canvasPt
        shapeCurrent = canvasPt
        setNeedsDisplay()
    }

    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, isDrawing || currentTool == .lasso else { return }
        if touches.count > 1 || event?.allTouches?.count ?? 0 > 1 {
            return
        }

        _ = stylusHelper.processTouch(touch)
        let loc = touch.location(in: self)
        var canvasPt = screenToCanvas(loc)
        canvasPt = rulerOverlay.snapPoint(canvasPt)

        if currentTool == .lasso {
            if lassoManager.isSelecting {
                lassoManager.addPoint(canvasPt)
                setNeedsDisplay()
            }
            return
        }

        if currentTool == .shapes {
            shapeCurrent = canvasPt
            setNeedsDisplay()
            return
        }

        activePoints.append(canvasPt)
        setNeedsDisplay()
    }

    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        _ = stylusHelper.processTouch(touch)

        if currentTool == .lasso {
            if lassoManager.isSelecting {
                guard let layer = project.activeLayer, let frame = project.currentFrame else { return }
                let currentImg = frame.getImage(for: layer.id)
                _ = lassoManager.finishSelection(sourceImage: currentImg)
                setNeedsDisplay()
            }
            return
        }

        if isDrawing {
            commitActiveStroke()
            isDrawing = false
            activePoints.removeAll()
            setNeedsDisplay()
            onProjectChanged?()
        }
    }

    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        isDrawing = false
        activePoints.removeAll()
        lassoManager.cancelSelection()
        setNeedsDisplay()
    }

    // MARK: - Stroke Rendering & Commit
    private func commitActiveStroke() {
        guard let layer = project.activeLayer, !layer.isLocked, let frame = project.currentFrame else { return }

        let canvasSize = project.canvasSize
        let existingImg = frame.getImage(for: layer.id)
        let effectiveWidth = stylusHelper.calculateStrokeWidth(baseWidth: brushSize)

        let renderer = UIGraphicsImageRenderer(size: canvasSize)
        let newImage = renderer.image { context in
            let cg = context.cgContext

            // 1. Draw existing layer
            existingImg?.draw(in: CGRect(origin: .zero, size: canvasSize))

            // 2. Alpha lock support
            if layer.isAlphaLocked {
                cg.setBlendMode(.sourceAtop)
            }

            // 3. Draw active stroke / shape
            if currentTool == .shapes {
                drawShape(in: cg, start: shapeStart, end: shapeCurrent, strokeWidth: effectiveWidth)
            } else {
                drawStroke(in: cg, points: activePoints, strokeWidth: effectiveWidth)
            }
        }

        frame.setImage(newImage, for: layer.id)
    }

    private func drawStroke(in cg: CGContext, points: [CGPoint], strokeWidth: CGFloat) {
        guard !points.isEmpty else { return }

        cg.saveGState()
        cg.setLineWidth(strokeWidth)
        cg.setLineCap(.round)
        cg.setLineJoin(.round)

        switch currentTool {
        case .pen:
            cg.setStrokeColor(brushColor.withAlphaComponent(brushOpacity).cgColor)
            renderSmoothPath(in: cg, points: points)
            cg.strokePath()

        case .pencil:
            cg.setStrokeColor(brushColor.withAlphaComponent(brushOpacity * 0.75).cgColor)
            cg.setLineWidth(max(1.0, strokeWidth * 0.6))
            renderSmoothPath(in: cg, points: points)
            cg.strokePath()

        case .brush:
            cg.setStrokeColor(brushColor.withAlphaComponent(brushOpacity * 0.85).cgColor)
            cg.setShadow(offset: .zero, blur: strokeWidth * 0.4, color: brushColor.cgColor)
            renderSmoothPath(in: cg, points: points)
            cg.strokePath()

        case .highlighter:
            cg.setStrokeColor(brushColor.withAlphaComponent(0.35).cgColor)
            cg.setLineCap(.square)
            cg.setLineWidth(strokeWidth * 2.2)
            renderSmoothPath(in: cg, points: points)
            cg.strokePath()

        case .eraser:
            cg.setBlendMode(.clear)
            renderSmoothPath(in: cg, points: points)
            cg.strokePath()

        case .smudge, .blur:
            cg.setStrokeColor(brushColor.withAlphaComponent(0.2).cgColor)
            cg.setShadow(offset: .zero, blur: strokeWidth * 0.8, color: UIColor.gray.cgColor)
            renderSmoothPath(in: cg, points: points)
            cg.strokePath()

        default:
            cg.setStrokeColor(brushColor.withAlphaComponent(brushOpacity).cgColor)
            renderSmoothPath(in: cg, points: points)
            cg.strokePath()
        }

        cg.restoreGState()
    }

    private func renderSmoothPath(in cg: CGContext, points: [CGPoint]) {
        if points.count == 1 {
            cg.addArc(center: points[0], radius: brushSize / 2, startAngle: 0, endAngle: .pi * 2, clockwise: true)
            return
        }

        cg.move(to: points[0])
        for i in 1..<points.count {
            let mid = CGPoint(
                x: (points[i-1].x + points[i].x) / 2.0,
                y: (points[i-1].y + points[i].y) / 2.0
            )
            cg.addQuadCurve(to: mid, control: points[i-1])
        }
        cg.addLine(to: points.last!)
    }

    private func drawShape(in cg: CGContext, start: CGPoint, end: CGPoint, strokeWidth: CGFloat) {
        cg.saveGState()
        cg.setStrokeColor(brushColor.withAlphaComponent(brushOpacity).cgColor)
        cg.setLineWidth(strokeWidth)

        switch currentShape {
        case .line:
            cg.move(to: start)
            cg.addLine(to: end)
            cg.strokePath()

        case .rectangle:
            let rect = CGRect(
                x: min(start.x, end.x),
                y: min(start.y, end.y),
                width: abs(end.x - start.x),
                height: abs(end.y - start.y)
            )
            cg.stroke(rect)

        case .circle:
            let rect = CGRect(
                x: min(start.x, end.x),
                y: min(start.y, end.y),
                width: abs(end.x - start.x),
                height: abs(end.y - start.y)
            )
            cg.strokeEllipse(in: rect)

        case .star:
            let center = CGPoint(x: (start.x + end.x) / 2, y: (start.y + end.y) / 2)
            let radius = max(abs(end.x - start.x), abs(end.y - start.y)) / 2
            drawStar(in: cg, center: center, radius: radius)
        }

        cg.restoreGState()
    }

    private func drawStar(in cg: CGContext, center: CGPoint, radius: CGFloat) {
        let pointsOnStar = 5
        var angle: CGFloat = -.pi / 2
        let angleIncrement = .pi * 2 / CGFloat(pointsOnStar * 2)

        cg.move(to: CGPoint(x: center.x + radius * cos(angle), y: center.y + radius * sin(angle)))
        for i in 1..<(pointsOnStar * 2) {
            angle += angleIncrement
            let r = (i % 2 == 0) ? radius : radius * 0.45
            cg.addLine(to: CGPoint(x: center.x + r * cos(angle), y: center.y + r * sin(angle)))
        }
        cg.closePath()
        cg.strokePath()
    }

    public func stampText(_ text: String, at point: CGPoint, fontSize: CGFloat = 36.0) {
        guard let layer = project.activeLayer, !layer.isLocked, let frame = project.currentFrame else { return }
        saveUndoSnapshot()

        let canvasSize = project.canvasSize
        let existingImg = frame.getImage(for: layer.id)

        let renderer = UIGraphicsImageRenderer(size: canvasSize)
        let newImg = renderer.image { _ in
            existingImg?.draw(in: CGRect(origin: .zero, size: canvasSize))

            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: fontSize, weight: .bold),
                .foregroundColor: brushColor
            ]
            let attrStr = NSAttributedString(string: text, attributes: attrs)
            attrStr.draw(at: point)
        }

        frame.setImage(newImg, for: layer.id)
        setNeedsDisplay()
        onProjectChanged?()
    }

    private func sampleColor(at point: CGPoint) {
        guard let currentFrame = project.currentFrame else { return }
        let composite = currentFrame.renderComposite(layers: project.layers, canvasSize: project.canvasSize, transparent: false)
        guard let cgImage = composite.cgImage else { return }
        let px = Int(point.x)
        let py = Int(point.y)
        guard px >= 0, px < cgImage.width, py >= 0, py < cgImage.height else { return }

        guard let data = cgImage.dataProvider?.data,
              let ptr = CFDataGetBytePtr(data) else { return }
        let bytesPerPixel = cgImage.bitsPerPixel / 8
        let bytesPerRow = cgImage.bytesPerRow
        let offset = py * bytesPerRow + px * bytesPerPixel

        let r = CGFloat(ptr[offset]) / 255.0
        let g = CGFloat(ptr[offset + 1]) / 255.0
        let b = CGFloat(ptr[offset + 2]) / 255.0
        self.brushColor = UIColor(red: r, green: g, blue: b, alpha: 1.0)
        self.currentTool = .pen
        setNeedsDisplay()
        onProjectChanged?()
    }

    private func applyFloodFill(at point: CGPoint) {
        guard let layer = project.activeLayer, !layer.isLocked, let frame = project.currentFrame else { return }
        saveUndoSnapshot()

        let baseImg = frame.getImage(for: layer.id) ?? UIImage.createBlank(size: project.canvasSize)
        if let filled = FloodFill.fill(image: baseImg, at: point, fillColor: brushColor) {
            frame.setImage(filled, for: layer.id)
            setNeedsDisplay()
            onProjectChanged?()
        }
    }

    public func commitLasso() {
        guard lassoManager.hasSelection, let layer = project.activeLayer, let frame = project.currentFrame else { return }
        saveUndoSnapshot()
        let existing = frame.getImage(for: layer.id)
        let committed = lassoManager.commitSelection(onto: existing, canvasSize: project.canvasSize)
        frame.setImage(committed, for: layer.id)
        setNeedsDisplay()
        onProjectChanged?()
    }

    // MARK: - Draw Viewport & Layers
    public override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        // Workspace background
        let workspaceBg = project.isDarkMode ? UIColor(hex: "#121418")! : UIColor(hex: "#E2E8F0")!
        context.setFillColor(workspaceBg.cgColor)
        context.fill(bounds)

        context.saveGState()
        context.translateBy(x: panOffset.x, y: panOffset.y)
        context.scaleBy(x: scaleFactor, y: scaleFactor)

        let cw = CGFloat(project.width)
        let ch = CGFloat(project.height)

        // Draw outside canvas draft area
        if project.drawOutsideCanvas {
            let draftColor = project.isDarkMode ? UIColor(hex: "#1A1D24")! : UIColor(hex: "#CBD5E1")!
            context.setFillColor(draftColor.cgColor)
            context.fill(CGRect(x: -cw * 0.4, y: -ch * 0.4, width: cw * 1.8, height: ch * 1.8))
        }

        // 1. Draw Canvas Paper Artboard
        let canvasBg = UIColor(hex: project.backgroundColorHex) ?? .white
        context.setFillColor(canvasBg.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: cw, height: ch))

        guard let currentFrame = project.currentFrame else {
            context.restoreGState()
            return
        }
        let currentIdx = project.currentFrameIndex

        // 2. Draw Onion Skin (Previous Frames in Red tint, Next Frames in Green tint)
        if isOnionSkinEnabled && !isDrawing {
            let startBefore = max(0, currentIdx - onionSkinFramesBefore)
            for i in startBefore..<currentIdx {
                let f = project.frames[i]
                let dist = currentIdx - i
                let alpha = (onionSkinAlpha / CGFloat(dist))
                let comp = f.renderComposite(layers: project.layers, canvasSize: project.canvasSize, transparent: true)
                if let tinted = comp.tinted(with: .systemRed) {
                    context.saveGState()
                    context.setAlpha(alpha)
                    tinted.draw(in: CGRect(x: 0, y: 0, width: cw, height: ch))
                    context.restoreGState()
                }
            }

            let endAfter = min(project.frames.count - 1, currentIdx + onionSkinFramesAfter)
            if currentIdx + 1 <= endAfter {
                for i in (currentIdx + 1)...endAfter {
                    let f = project.frames[i]
                    let dist = i - currentIdx
                    let alpha = (onionSkinAlpha / CGFloat(dist))
                    let comp = f.renderComposite(layers: project.layers, canvasSize: project.canvasSize, transparent: true)
                    if let tinted = comp.tinted(with: .systemGreen) {
                        context.saveGState()
                        context.setAlpha(alpha)
                        tinted.draw(in: CGRect(x: 0, y: 0, width: cw, height: ch))
                        context.restoreGState()
                    }
                }
            }
        }

        // 3. Draw Rotoscoping Reference Image
        if let ref = currentFrame.referenceImage {
            context.saveGState()
            context.setAlpha(CGFloat(currentFrame.referenceOpacity))
            ref.draw(in: CGRect(x: 0, y: 0, width: cw, height: ch))
            context.restoreGState()
        }

        // 4. Draw Current Frame Layers (Bottom to Top)
        for layer in project.layers where layer.isVisible {
            guard let img = currentFrame.getImage(for: layer.id) else { continue }
            context.saveGState()
            context.setAlpha(CGFloat(layer.opacity))
            context.setBlendMode(layer.blendMode.toCGBlendMode())

            if layer.isClippingMask {
                context.setBlendMode(.sourceAtop)
            }

            var finalImg = img
            if layer.pixelEffectSize > 1 {
                finalImg = finalImg.pixelated(pixelSize: layer.pixelEffectSize) ?? img
            }
            if layer.blurRadius > 0 {
                finalImg = finalImg.blurred(radius: layer.blurRadius) ?? finalImg
            }

            // Glow FX
            if layer.glowRadius > 0, let glowColor = UIColor(hex: layer.glowColorHex) {
                context.saveGState()
                context.setShadow(offset: .zero, blur: layer.glowRadius, color: glowColor.cgColor)
                finalImg.draw(in: CGRect(x: 0, y: 0, width: cw, height: ch))
                context.restoreGState()
            }

            finalImg.draw(in: CGRect(x: 0, y: 0, width: cw, height: ch))
            context.restoreGState()
        }

        // 5. Draw In-Progress Live Stroke or Shape
        if isDrawing {
            let effectiveWidth = stylusHelper.calculateStrokeWidth(baseWidth: brushSize)
            if currentTool == .shapes {
                drawShape(in: context, start: shapeStart, end: shapeCurrent, strokeWidth: effectiveWidth)
            } else {
                drawStroke(in: context, points: activePoints, strokeWidth: effectiveWidth)
            }
        }

        // 6. Draw Lasso & Ruler Overlays
        lassoManager.drawOverlay(in: context)
        rulerOverlay.draw(in: context)

        // 6b. Alignment Grid Overlay
        if isGridVisible {
            context.saveGState()
            context.setStrokeColor(project.isDarkMode ? UIColor(white: 1.0, alpha: 0.12).cgColor : UIColor(white: 0.0, alpha: 0.12).cgColor)
            context.setLineWidth(1.0 / scaleFactor)
            let step: CGFloat = 40.0
            var x: CGFloat = 0
            while x <= cw {
                context.move(to: CGPoint(x: x, y: 0))
                context.addLine(to: CGPoint(x: x, y: ch))
                x += step
            }
            var y: CGFloat = 0
            while y <= ch {
                context.move(to: CGPoint(x: 0, y: y))
                context.addLine(to: CGPoint(x: cw, y: y))
                y += step
            }
            context.strokePath()
            context.restoreGState()
        }

        // 7. Artboard Border & Dimension indicator
        context.setStrokeColor(project.isDarkMode ? UIColor(white: 1.0, alpha: 0.25).cgColor : UIColor(white: 0.0, alpha: 0.25).cgColor)
        context.setLineWidth(2.0 / scaleFactor)
        context.stroke(CGRect(x: 0, y: 0, width: cw, height: ch))

        context.restoreGState()
    }
}

// MARK: - SwiftUI Representable Wrapper
public struct CanvasViewRepresentable: UIViewRepresentable {
    @ObservedObject public var project: Project
    @Binding public var currentTool: ToolType
    @Binding public var currentShape: ShapeType
    @Binding public var brushColor: Color
    @Binding public var brushSize: CGFloat
    @Binding public var brushOpacity: CGFloat
    @Binding public var isOnionSkinEnabled: Bool
    @Binding public var isGridVisible: Bool
    @Binding public var rulerType: RulerType

    public let drawingView: CanvasDrawingView

    public init(
        project: Project,
        currentTool: Binding<ToolType>,
        currentShape: Binding<ShapeType>,
        brushColor: Binding<Color>,
        brushSize: Binding<CGFloat>,
        brushOpacity: Binding<CGFloat>,
        isOnionSkinEnabled: Binding<Bool>,
        isGridVisible: Binding<Bool>,
        rulerType: Binding<RulerType>,
        drawingView: CanvasDrawingView
    ) {
        self.project = project
        self._currentTool = currentTool
        self._currentShape = currentShape
        self._brushColor = brushColor
        self._brushSize = brushSize
        self._brushOpacity = brushOpacity
        self._isOnionSkinEnabled = isOnionSkinEnabled
        self._isGridVisible = isGridVisible
        self._rulerType = rulerType
        self.drawingView = drawingView
    }

    public func makeUIView(context: Context) -> CanvasDrawingView {
        drawingView.resetViewport()
        return drawingView
    }

    public func updateUIView(_ uiView: CanvasDrawingView, context: Context) {
        uiView.project = project
        uiView.currentTool = currentTool
        uiView.currentShape = currentShape
        uiView.brushColor = UIColor(brushColor)
        uiView.brushSize = brushSize
        uiView.brushOpacity = brushOpacity
        uiView.isOnionSkinEnabled = isOnionSkinEnabled
        uiView.isGridVisible = isGridVisible
        uiView.rulerOverlay.rulerType = rulerType
        uiView.setNeedsDisplay()
    }
}
