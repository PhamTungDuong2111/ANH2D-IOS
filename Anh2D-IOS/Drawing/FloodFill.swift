import UIKit

public struct FloodFill {
    public static func fill(
        image: UIImage,
        at startPoint: CGPoint,
        fillColor: UIColor,
        tolerance: Int = 32
    ) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }

        let width = cgImage.width
        let height = cgImage.height

        let startX = Int(startPoint.x)
        let startY = Int(startPoint.y)

        guard startX >= 0, startX < width, startY >= 0, startY < height else {
            return image
        }

        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8

        var rawData = [UInt8](repeating: 0, count: height * bytesPerRow)
        let colorSpace = CGColorSpaceCreateDeviceRGB()

        guard let context = CGContext(
            data: &rawData,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
        ) else { return nil }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        // Get target color at startPoint
        let startIndex = (startY * width + startX) * 4
        let targetR = Int(rawData[startIndex])
        let targetG = Int(rawData[startIndex + 1])
        let targetB = Int(rawData[startIndex + 2])
        let targetA = Int(rawData[startIndex + 3])

        var fr: CGFloat = 0, fg: CGFloat = 0, fb: CGFloat = 0, fa: CGFloat = 0
        fillColor.getRed(&fr, green: &fg, blue: &fb, alpha: &fa)
        let newR = UInt8(fr * 255)
        let newG = UInt8(fg * 255)
        let newB = UInt8(fb * 255)
        let newA = UInt8(fa * 255)

        // Don't fill if same color
        if abs(targetR - Int(newR)) <= 5 && abs(targetG - Int(newG)) <= 5 &&
           abs(targetB - Int(newB)) <= 5 && abs(targetA - Int(newA)) <= 5 {
            return image
        }

        var visited = [Bool](repeating: false, count: width * height)
        var queue = [Int]()
        queue.reserveCapacity(width * height / 4)

        let startPixelIdx = startY * width + startX
        queue.append(startPixelIdx)
        visited[startPixelIdx] = true

        var head = 0
        while head < queue.count {
            let pixelIdx = queue[head]
            head += 1

            let byteIdx = pixelIdx * 4
            rawData[byteIdx] = newR
            rawData[byteIdx + 1] = newG
            rawData[byteIdx + 2] = newB
            rawData[byteIdx + 3] = newA

            let cx = pixelIdx % width
            let cy = pixelIdx / width

            // 4-neighbor check
            let neighbors = [
                (cx > 0) ? pixelIdx - 1 : -1,
                (cx < width - 1) ? pixelIdx + 1 : -1,
                (cy > 0) ? pixelIdx - width : -1,
                (cy < height - 1) ? pixelIdx + width : -1
            ]

            for n in neighbors where n >= 0 && !visited[n] {
                let nbByteIdx = n * 4
                let nr = Int(rawData[nbByteIdx])
                let ng = Int(rawData[nbByteIdx + 1])
                let nb = Int(rawData[nbByteIdx + 2])
                let na = Int(rawData[nbByteIdx + 3])

                let diff = abs(nr - targetR) + abs(ng - targetG) + abs(nb - targetB) + abs(na - targetA)
                if diff <= tolerance * 4 {
                    visited[n] = true
                    queue.append(n)
                }
            }
        }

        guard let outputCG = context.makeImage() else { return nil }
        return UIImage(cgImage: outputCG, scale: image.scale, orientation: image.imageOrientation)
    }
}
