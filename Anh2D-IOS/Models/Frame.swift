import UIKit

public final class Frame: Identifiable {
    public let id: UUID
    public var holdDuration: Int
    public var layerImages: [UUID: UIImage]
    public var referenceImage: UIImage?
    public var referenceOpacity: Float
    public var cachedThumbnail: UIImage?

    public init(
        id: UUID = UUID(),
        holdDuration: Int = 1,
        layerImages: [UUID: UIImage] = [:],
        referenceImage: UIImage? = nil,
        referenceOpacity: Float = 0.4
    ) {
        self.id = id
        self.holdDuration = holdDuration
        self.layerImages = layerImages
        self.referenceImage = referenceImage
        self.referenceOpacity = referenceOpacity
    }

    public func getImage(for layerId: UUID) -> UIImage? {
        return layerImages[layerId]
    }

    public func setImage(_ image: UIImage?, for layerId: UUID) {
        layerImages[layerId] = image
        cachedThumbnail = nil
    }

    public func clone() -> Frame {
        var clonedImages: [UUID: UIImage] = [:]
        for (layerId, img) in layerImages {
            if let cg = img.cgImage {
                clonedImages[layerId] = UIImage(cgImage: cg, scale: img.scale, orientation: img.imageOrientation)
            }
        }
        var clonedRef: UIImage? = nil
        if let ref = referenceImage, let cg = ref.cgImage {
            clonedRef = UIImage(cgImage: cg, scale: ref.scale, orientation: ref.imageOrientation)
        }
        return Frame(
            id: UUID(),
            holdDuration: holdDuration,
            layerImages: clonedImages,
            referenceImage: clonedRef,
            referenceOpacity: referenceOpacity
        )
    }

    public func renderComposite(
        layers: [Layer],
        canvasSize: CGSize,
        transparent: Bool = false,
        backgroundColor: UIColor = .white
    ) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: canvasSize)
        return renderer.image { context in
            let cgContext = context.cgContext

            if !transparent {
                cgContext.setFillColor(backgroundColor.cgColor)
                cgContext.fill(CGRect(origin: .zero, size: canvasSize))
            }

            // Draw rotoscoping reference if present
            if let ref = referenceImage {
                cgContext.saveGState()
                cgContext.setAlpha(CGFloat(referenceOpacity))
                ref.draw(in: CGRect(origin: .zero, size: canvasSize))
                cgContext.restoreGState()
            }

            // Draw layers bottom to top
            for layer in layers where layer.isVisible {
                guard let img = layerImages[layer.id] else { continue }
                cgContext.saveGState()
                cgContext.setAlpha(CGFloat(layer.opacity))
                cgContext.setBlendMode(layer.blendMode.toCGBlendMode())

                if layer.isClippingMask {
                    cgContext.setBlendMode(.sourceAtop)
                }

                // Render with pixelate / blur if needed
                var finalImg = img
                if layer.pixelEffectSize > 1 {
                    finalImg = finalImg.pixelated(pixelSize: layer.pixelEffectSize) ?? img
                }
                if layer.blurRadius > 0 {
                    finalImg = finalImg.blurred(radius: layer.blurRadius) ?? finalImg
                }

                // Glow effect under layer
                if layer.glowRadius > 0, let glowColor = UIColor(hex: layer.glowColorHex) {
                    cgContext.saveGState()
                    cgContext.setShadow(offset: .zero, blur: layer.glowRadius, color: glowColor.cgColor)
                    finalImg.draw(in: CGRect(origin: .zero, size: canvasSize))
                    cgContext.restoreGState()
                }

                finalImg.draw(in: CGRect(origin: .zero, size: canvasSize))
                cgContext.restoreGState()
            }
        }
    }
}
