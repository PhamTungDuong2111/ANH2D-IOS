import Foundation
import UIKit

public final class Project: ObservableObject, Identifiable {
    public let id: UUID
    @Published public var title: String
    @Published public var width: Int
    @Published public var height: Int
    @Published public var fps: Int
    @Published public var backgroundColorHex: String
    @Published public var preset: CanvasPreset
    @Published public var isPlusUnlocked: Bool
    @Published public var drawOutsideCanvas: Bool
    @Published public var isDarkMode: Bool
    @Published public var stylusOnlyMode: Bool
    @Published public var layers: [Layer]
    @Published public var frames: [Frame]
    @Published public var audioTracks: [AudioTrack]
    @Published public var activeLayerIndex: Int
    @Published public var currentFrameIndex: Int

    public init(
        id: UUID = UUID(),
        title: String = "Quả bóng nảy",
        width: Int = 1280,
        height: Int = 720,
        fps: Int = 12,
        backgroundColorHex: String = "#FFFFFF",
        preset: CanvasPreset = .youtube16_9,
        isPlusUnlocked: Bool = true,
        drawOutsideCanvas: Bool = true,
        isDarkMode: Bool = true,
        stylusOnlyMode: Bool = false,
        layers: [Layer] = [],
        frames: [Frame] = [],
        audioTracks: [AudioTrack] = [],
        activeLayerIndex: Int = 0,
        currentFrameIndex: Int = 0
    ) {
        self.id = id
        self.title = title
        self.width = width
        self.height = height
        self.fps = fps
        self.backgroundColorHex = backgroundColorHex
        self.preset = preset
        self.isPlusUnlocked = isPlusUnlocked
        self.drawOutsideCanvas = drawOutsideCanvas
        self.isDarkMode = isDarkMode
        self.stylusOnlyMode = stylusOnlyMode
        self.layers = layers
        self.frames = frames
        self.audioTracks = audioTracks
        self.activeLayerIndex = activeLayerIndex
        self.currentFrameIndex = currentFrameIndex
    }

    public static func createDefault() -> Project {
        return createSampleBouncingBallProject()
    }

    public static func createEmpty(title: String = "Dự án mới", preset: CanvasPreset = .youtube16_9, fps: Int = 12, bgHex: String = "#FFFFFF") -> Project {
        let dims = preset.dimensions
        let proj = Project(
            title: title,
            width: dims.width,
            height: dims.height,
            fps: fps,
            backgroundColorHex: bgHex,
            preset: preset
        )
        proj.layers = [
            Layer(name: "Lớp 1")
        ]
        proj.activeLayerIndex = 0
        proj.frames = [Frame()]
        proj.currentFrameIndex = 0
        return proj
    }

    // MARK: - Preloaded Sample Animation: Quả bóng nảy (Bouncing Ball - matching ADR)
    public static func createSampleBouncingBallProject() -> Project {
        let width = 1280
        let height = 720
        let layer1 = Layer(name: "Lớp 1 (Ball)")

        struct BallPos {
            let x: CGFloat
            let y: CGFloat
            let rx: CGFloat
            let ry: CGFloat
            let angle: CGFloat
        }

        let ballPositions: [BallPos] = [
            BallPos(x: 300, y: 180, rx: 45, ry: 45, angle: 0),
            BallPos(x: 420, y: 280, rx: 42, ry: 50, angle: 0.2),
            BallPos(x: 550, y: 440, rx: 38, ry: 58, angle: 0.35),
            BallPos(x: 680, y: 580, rx: 70, ry: 25, angle: 0),
            BallPos(x: 790, y: 450, rx: 38, ry: 58, angle: -0.3),
            BallPos(x: 900, y: 300, rx: 42, ry: 48, angle: -0.15),
            BallPos(x: 990, y: 220, rx: 45, ry: 45, angle: 0),
            BallPos(x: 1050, y: 280, rx: 44, ry: 48, angle: 0.1)
        ]

        let canvasSize = CGSize(width: width, height: height)
        let renderer = UIGraphicsImageRenderer(size: canvasSize)

        var framesList: [Frame] = []

        for (idx, pos) in ballPositions.enumerated() {
            let img = renderer.image { context in
                let cg = context.cgContext

                // 1. Ground line
                cg.setStrokeColor(UIColor(hex: "#4A5568")!.cgColor)
                cg.setLineWidth(6.0)
                cg.setLineCap(.round)
                cg.beginPath()
                cg.move(to: CGPoint(x: 150, y: 600))
                cg.addLine(to: CGPoint(x: 1130, y: 600))
                cg.strokePath()

                // 2. Shadow on ground
                let shadowScale = max(0.2, 1.0 - (600.0 - pos.y) / 500.0)
                cg.setFillColor(UIColor.black.withAlphaComponent(0.18).cgColor)
                cg.fillEllipse(in: CGRect(
                    x: pos.x - 60 * shadowScale,
                    y: 600 - 12 * shadowScale,
                    width: 120 * shadowScale,
                    height: 24 * shadowScale
                ))

                // 3. Ball with squash / stretch & 3D sheen
                cg.saveGState()
                cg.translateBy(x: pos.x, y: pos.y)
                cg.rotate(by: pos.angle)

                let ballRect = CGRect(x: -pos.rx, y: -pos.ry, width: pos.rx * 2, height: pos.ry * 2)

                // Fill gradient (coral/red)
                cg.saveGState()
                cg.addEllipse(in: ballRect)
                cg.clip()

                let colors = [
                    UIColor(hex: "#FFA07A")!.cgColor,
                    UIColor(hex: "#FF4500")!.cgColor,
                    UIColor(hex: "#B22222")!.cgColor
                ] as CFArray
                let colorSpace = CGColorSpaceCreateDeviceRGB()
                if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: [0.0, 0.5, 1.0]) {
                    cg.drawRadialGradient(
                        gradient,
                        startCenter: CGPoint(x: -pos.rx * 0.3, y: -pos.ry * 0.3),
                        startRadius: pos.rx * 0.1,
                        endCenter: .zero,
                        endRadius: pos.rx,
                        options: [.drawsBeforeStartLocation, .drawsAfterEndLocation]
                    )
                }
                cg.restoreGState()

                // Border outline
                cg.setStrokeColor(UIColor(hex: "#800000")!.cgColor)
                cg.setLineWidth(5.0)
                cg.strokeEllipse(in: ballRect)

                // Specular highlight sheen
                cg.setFillColor(UIColor.white.withAlphaComponent(0.7).cgColor)
                cg.fillEllipse(in: CGRect(
                    x: -pos.rx * 0.45,
                    y: -pos.ry * 0.45,
                    width: pos.rx * 0.55,
                    height: pos.ry * 0.35
                ))

                // Motion lines on fast fall (idx == 2) or fast rebound (idx == 4)
                if idx == 2 || idx == 4 {
                    cg.setStrokeColor(UIColor(hex: "#FF5353")!.withAlphaComponent(0.6).cgColor)
                    cg.setLineWidth(4.0)
                    cg.setLineCap(.round)
                    cg.beginPath()
                    cg.move(to: CGPoint(x: -pos.rx - 15, y: 0))
                    cg.addLine(to: CGPoint(x: -pos.rx - 45, y: -20))
                    cg.strokePath()
                }

                cg.restoreGState()
            }

            let frame = Frame()
            frame.setImage(img, for: layer1.id)
            framesList.append(frame)
        }

        let proj = Project(
            title: "Quả bóng nảy (Bouncing Ball)",
            width: width,
            height: height,
            fps: 12,
            backgroundColorHex: "#FFFFFF",
            preset: .youtube16_9,
            layers: [layer1],
            frames: framesList
        )
        proj.activeLayerIndex = 0
        proj.currentFrameIndex = 0
        return proj
    }

    public static func createSampleStickmanProject() -> Project {
        let width = 1280
        let height = 720
        let layer1 = Layer(name: "Lớp 1 (Stickman)")

        let canvasSize = CGSize(width: width, height: height)
        let renderer = UIGraphicsImageRenderer(size: canvasSize)

        // 6 frames of stickman running
        let legAngles: [(l1: CGFloat, l2: CGFloat, a1: CGFloat, a2: CGFloat)] = [
            (-0.6, 0.6, 0.5, -0.5),
            (-0.3, 0.3, 0.2, -0.2),
            (0.1, -0.1, -0.2, 0.2),
            (0.6, -0.6, -0.5, 0.5),
            (0.3, -0.3, -0.2, 0.2),
            (-0.1, 0.1, 0.2, -0.2)
        ]

        var framesList: [Frame] = []

        for (idx, angles) in legAngles.enumerated() {
            let cx: CGFloat = 350 + CGFloat(idx) * 90
            let cy: CGFloat = 380

            let img = renderer.image { context in
                let cg = context.cgContext

                // Ground
                cg.setStrokeColor(UIColor(hex: "#4A5568")!.cgColor)
                cg.setLineWidth(6.0)
                cg.setLineCap(.round)
                cg.beginPath()
                cg.move(to: CGPoint(x: 100, y: 560))
                cg.addLine(to: CGPoint(x: 1180, y: 560))
                cg.strokePath()

                // Stickman
                cg.setStrokeColor(UIColor(hex: "#FF5353")!.cgColor)
                cg.setFillColor(UIColor(hex: "#FF5353")!.cgColor)
                cg.setLineWidth(7.0)
                cg.setLineCap(.round)
                cg.setLineJoin(.round)

                // Head
                cg.fillEllipse(in: CGRect(x: cx - 22, y: cy - 90, width: 44, height: 44))

                // Torso
                cg.beginPath()
                cg.move(to: CGPoint(x: cx, y: cy - 46))
                cg.addLine(to: CGPoint(x: cx - 10, y: cy + 40))
                cg.strokePath()

                // Arms
                cg.beginPath()
                cg.move(to: CGPoint(x: cx - 5, y: cy - 30))
                cg.addLine(to: CGPoint(x: cx - 5 + cos(angles.a1) * 45, y: cy - 30 + sin(angles.a1) * 45))
                cg.strokePath()

                cg.beginPath()
                cg.move(to: CGPoint(x: cx - 5, y: cy - 30))
                cg.addLine(to: CGPoint(x: cx - 5 + cos(angles.a2) * 45, y: cy - 30 + sin(angles.a2) * 45))
                cg.strokePath()

                // Legs
                cg.beginPath()
                cg.move(to: CGPoint(x: cx - 10, y: cy + 40))
                cg.addLine(to: CGPoint(x: cx - 10 + sin(angles.l1) * 65, y: cy + 40 + cos(angles.l1) * 65))
                cg.strokePath()

                cg.beginPath()
                cg.move(to: CGPoint(x: cx - 10, y: cy + 40))
                cg.addLine(to: CGPoint(x: cx - 10 + sin(angles.l2) * 65, y: cy + 40 + cos(angles.l2) * 65))
                cg.strokePath()
            }

            let frame = Frame()
            frame.setImage(img, for: layer1.id)
            framesList.append(frame)
        }

        let proj = Project(
            title: "Người que chạy (Stickman)",
            width: width,
            height: height,
            fps: 12,
            backgroundColorHex: "#FFFFFF",
            preset: .youtube16_9,
            layers: [layer1],
            frames: framesList
        )
        return proj
    }

    public func duplicate() -> Project {
        let copy = Project(
            title: "\(title) (Bản sao)",
            width: width,
            height: height,
            fps: fps,
            backgroundColorHex: backgroundColorHex,
            preset: preset,
            isPlusUnlocked: isPlusUnlocked,
            drawOutsideCanvas: drawOutsideCanvas,
            isDarkMode: isDarkMode,
            stylusOnlyMode: stylusOnlyMode
        )

        // Clone layers
        copy.layers = layers.map { $0.duplicate() }
        copy.activeLayerIndex = activeLayerIndex

        // Clone frames
        var newFrames: [Frame] = []
        for frame in frames {
            let newFrame = Frame(holdDuration: frame.holdDuration)
            newFrame.referenceImage = frame.referenceImage
            newFrame.referenceOpacity = frame.referenceOpacity
            for (originalLayer, newLayer) in zip(layers, copy.layers) {
                if let img = frame.getImage(for: originalLayer.id) {
                    newFrame.setImage(img, for: newLayer.id)
                }
            }
            newFrames.append(newFrame)
        }
        copy.frames = newFrames
        copy.currentFrameIndex = currentFrameIndex
        return copy
    }

    public var canvasSize: CGSize {
        CGSize(width: width, height: height)
    }

    public var activeLayer: Layer? {
        guard activeLayerIndex >= 0 && activeLayerIndex < layers.count else {
            return layers.first
        }
        return layers[activeLayerIndex]
    }

    public var currentFrame: Frame? {
        guard currentFrameIndex >= 0 && currentFrameIndex < frames.count else {
            return frames.first
        }
        return frames[currentFrameIndex]
    }

    public func setPreset(_ newPreset: CanvasPreset) {
        preset = newPreset
        let dims = newPreset.dimensions
        width = dims.width
        height = dims.height
    }
}
