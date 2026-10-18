import UIKit
import CoreImage
import Vision

public final class MagicCutEngine {

    /// Automatically isolates subject/character and cuts out the background.
    public static func autoCutout(sourceImage: UIImage, tolerance: Int = 36) -> UIImage {
        if #available(iOS 17.0, *) {
            if let visionCutout = runVisionForegroundCutout(sourceImage: sourceImage) {
                return visionCutout
            }
        }

        // Fast high-quality border flood cutout fallback
        return runBorderFloodCutout(sourceImage: sourceImage, tolerance: tolerance)
    }

    @available(iOS 17.0, *)
    private static func runVisionForegroundCutout(sourceImage: UIImage) -> UIImage? {
        guard let cgImage = sourceImage.cgImage else { return nil }
        let request = VNGenerateForegroundInstanceMaskRequest()
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        do {
            try handler.perform([request])
            guard let result = request.results?.first else { return nil }
            let maskPixelBuffer = try result.generateScaledMaskForImage(forInstances: result.allInstances, from: handler)

            let ciImage = CIImage(cgImage: cgImage)
            let maskImage = CIImage(cvPixelBuffer: maskPixelBuffer)

            let filter = CIFilter(name: "CIBlendWithMask")
            filter?.setValue(ciImage, forKey: kCIInputImageKey)
            filter?.setValue(CIImage.empty(), forKey: kCIInputBackgroundImageKey)
            filter?.setValue(maskImage, forKey: kCIInputMaskImageKey)

            guard let outputCI = filter?.outputImage else { return nil }
            let context = CIContext(options: nil)
            guard let outputCG = context.createCGImage(outputCI, from: outputCI.extent) else { return nil }
            return UIImage(cgImage: outputCG, scale: sourceImage.scale, orientation: sourceImage.imageOrientation)
        } catch {
            return nil
        }
    }

    private static func runBorderFloodCutout(sourceImage: UIImage, tolerance: Int) -> UIImage {
        guard let cgImage = sourceImage.cgImage else { return sourceImage }
        let width = cgImage.width
        let height = cgImage.height

        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        var rawData = [UInt8](repeating: 0, count: height * bytesPerRow)
        let colorSpace = CGColorSpaceCreateDeviceRGB()

        guard let context = CGContext(
            data: &rawData,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
        ) else { return sourceImage }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        var queue = [Int]()
        queue.reserveCapacity(width * height / 4)
        var visited = [Bool](repeating: false, count: width * height)

        var borderR: Int = 0, borderG: Int = 0, borderB: Int = 0, sampleCount: Int = 0

        // 1. Collect perimeter seed samples
        for x in stride(from: 0, to: width, by: 6) {
            let topIdx = x
            let botIdx = (height - 1) * width + x

            borderR += Int(rawData[topIdx * 4])
            borderG += Int(rawData[topIdx * 4 + 1])
            borderB += Int(rawData[topIdx * 4 + 2])
            sampleCount += 1

            queue.append(topIdx)
            queue.append(botIdx)
            visited[topIdx] = true
            visited[botIdx] = true
        }

        for y in stride(from: 0, to: height, by: 6) {
            let leftIdx = y * width
            let rightIdx = y * width + (width - 1)

            borderR += Int(rawData[leftIdx * 4])
            borderG += Int(rawData[leftIdx * 4 + 1])
            borderB += Int(rawData[leftIdx * 4 + 2])
            sampleCount += 1

            queue.append(leftIdx)
            queue.append(rightIdx)
            visited[leftIdx] = true
            visited[rightIdx] = true
        }

        let avgR = borderR / max(1, sampleCount)
        let avgG = borderG / max(1, sampleCount)
        let avgB = borderB / max(1, sampleCount)

        // 2. Flood cutout from border inward
        var head = 0
        while head < queue.count {
            let idx = queue[head]
            head += 1

            let byteIdx = idx * 4
            let r = Int(rawData[byteIdx])
            let g = Int(rawData[byteIdx + 1])
            let b = Int(rawData[byteIdx + 2])

            let dist = abs(r - avgR) + abs(g - avgG) + abs(b - avgB)
            if dist <= tolerance * 3 {
                // Clear to transparent
                rawData[byteIdx] = 0
                rawData[byteIdx + 1] = 0
                rawData[byteIdx + 2] = 0
                rawData[byteIdx + 3] = 0

                let cx = idx % width
                let cy = idx / width

                let neighbors = [
                    (cx > 0) ? idx - 1 : -1,
                    (cx < width - 1) ? idx + 1 : -1,
                    (cy > 0) ? idx - width : -1,
                    (cy < height - 1) ? idx + width : -1
                ]

                for n in neighbors where n >= 0 && !visited[n] {
                    visited[n] = true
                    queue.append(n)
                }
            }
        }

        guard let outputCG = context.makeImage() else { return sourceImage }
        return UIImage(cgImage: outputCG, scale: sourceImage.scale, orientation: sourceImage.imageOrientation)
    }
}
