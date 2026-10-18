import UIKit
import SwiftUI

public struct Layer: Identifiable, Equatable {
    public var id: UUID
    public var name: String
    public var isVisible: Bool
    public var isLocked: Bool
    public var opacity: Float
    public var blendMode: BlendMode
    public var isClippingMask: Bool
    public var isAlphaLocked: Bool
    public var glowRadius: CGFloat
    public var glowColorHex: String
    public var blurRadius: CGFloat
    public var pixelEffectSize: Int

    public init(
        id: UUID = UUID(),
        name: String = "Layer 1",
        isVisible: Bool = true,
        isLocked: Bool = false,
        opacity: Float = 1.0,
        blendMode: BlendMode = .normal,
        isClippingMask: Bool = false,
        isAlphaLocked: Bool = false,
        glowRadius: CGFloat = 0.0,
        glowColorHex: String = "#FFFF00",
        blurRadius: CGFloat = 0.0,
        pixelEffectSize: Int = 1
    ) {
        self.id = id
        self.name = name
        self.isVisible = isVisible
        self.isLocked = isLocked
        self.opacity = opacity
        self.blendMode = blendMode
        self.isClippingMask = isClippingMask
        self.isAlphaLocked = isAlphaLocked
        self.glowRadius = glowRadius
        self.glowColorHex = glowColorHex
        self.blurRadius = blurRadius
        self.pixelEffectSize = pixelEffectSize
    }

    public func duplicate() -> Layer {
        Layer(
            id: UUID(),
            name: "\(name) Copy",
            isVisible: isVisible,
            isLocked: isLocked,
            opacity: opacity,
            blendMode: blendMode,
            isClippingMask: isClippingMask,
            isAlphaLocked: isAlphaLocked,
            glowRadius: glowRadius,
            glowColorHex: glowColorHex,
            blurRadius: blurRadius,
            pixelEffectSize: pixelEffectSize
        )
    }
}
