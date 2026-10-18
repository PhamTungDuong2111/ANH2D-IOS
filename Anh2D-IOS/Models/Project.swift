import Foundation
import UIKit

public final class Project: ObservableObject {
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
        title: String = "My Animation",
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
        let proj = Project()

        // 3 initial layers (up to 10 supported)
        proj.layers = [
            Layer(name = "Layer 1"),
            Layer(name = "Layer 2"),
            Layer(name = "Layer 3")
        ]
        proj.activeLayerIndex = 0

        // Initial Frame
        let firstFrame = Frame()
        proj.frames = [firstFrame]
        proj.currentFrameIndex = 0

        // Default Audio Tracks (up to 6)
        proj.audioTracks = [
            AudioTrack(name: "Voice 1"),
            AudioTrack(name: "Sound FX")
        ]

        return proj
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
