import UIKit
import CoreImage

public extension UIImage {
    func blurred(radius: CGFloat) -> UIImage? {
        guard let ciImg = CIImage(image: self) else { return nil }
        let filter = CIFilter(name: "CIGaussianBlur")
        filter?.setValue(ciImg, forKey: kCIInputImageKey)
        filter?.setValue(radius, forKey: kCIInputRadiusKey)
        guard let output = filter?.outputImage else { return nil }

        let context = CIContext(options: nil)
        guard let cg = context.createCGImage(output, from: ciImg.extent) else { return nil }
        return UIImage(cgImage: cg, scale: scale, orientation: imageOrientation)
    }

    func pixelated(pixelSize: Int) -> UIImage? {
        guard pixelSize > 1, let ciImg = CIImage(image: self) else { return self }
        let filter = CIFilter(name: "CIPixellate")
        filter?.setValue(ciImg, forKey: kCIInputImageKey)
        filter?.setValue(Float(pixelSize), forKey: kCIInputScaleKey)
        guard let output = filter?.outputImage else { return self }

        let context = CIContext(options: nil)
        guard let cg = context.createCGImage(output, from: ciImg.extent) else { return self }
        return UIImage(cgImage: cg, scale: scale, orientation: imageOrientation)
    }

    func tinted(with color: UIColor) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            let rect = CGRect(origin: .zero, size: size)
            color.set()
            context.fill(rect)
            draw(in: rect, blendMode: .destinationIn, alpha: 1.0)
        }
    }

    func resized(to newSize: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
    }

    static func createBlank(size: CGSize, color: UIColor = .clear) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
}
