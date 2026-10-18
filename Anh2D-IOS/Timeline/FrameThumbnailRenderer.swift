import UIKit

public struct FrameThumbnailRenderer {
    public static func renderThumbnail(
        for frame: Frame,
        project: Project,
        targetSize: CGSize = CGSize(width: 80, height: 50)
    ) -> UIImage {
        if let cached = frame.cachedThumbnail {
            return cached
        }

        let fullComposite = frame.renderComposite(
            layers: project.layers,
            canvasSize: project.canvasSize,
            transparent: false,
            backgroundColor: UIColor(hex: project.backgroundColorHex) ?? .white
        )

        let thumb = fullComposite.resized(to: targetSize) ?? fullComposite
        frame.cachedThumbnail = thumb
        return thumb
    }
}
