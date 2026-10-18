import UIKit
import ImageIO
import UniformTypeIdentifiers

public final class AnimatedGifEncoder {
    public static func createGif(
        from images: [UIImage],
        frameDelay: Double,
        loopCount: Int = 0
    ) -> Data? {
        guard !images.isEmpty else { return nil }

        let fileProperties: [CFString: Any] = [
            kCGImagePropertyGIFDictionary: [
                kCGImagePropertyGIFLoopCount: loopCount
            ]
        ]

        let frameProperties: [CFString: Any] = [
            kCGImagePropertyGIFDictionary: [
                kCGImagePropertyGIFDelayTime: frameDelay
            ]
        ]

        let data = NSMutableData()
        let typeIdentifier = UTType.gif.identifier as CFString

        guard let destination = CGImageDestinationCreateWithData(
            data as CFMutableData,
            typeIdentifier,
            images.count,
            nil
        ) else { return nil }

        CGImageDestinationSetProperties(destination, fileProperties as CFDictionary)

        for img in images {
            if let cg = img.cgImage {
                CGImageDestinationAddImage(destination, cg, frameProperties as CFDictionary)
            }
        }

        guard CGImageDestinationFinalize(destination) else { return nil }
        return data as Data
    }
}
