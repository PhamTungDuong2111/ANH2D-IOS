import UIKit
import AVFoundation

public final class MovieExporter {

    // MARK: - Export MP4 Video
    public static func exportMp4(
        project: Project,
        onProgress: @escaping (Int, Int) -> Void,
        completion: @escaping (Result<URL, Error>) -> Void
    ) {
        DispatchQueue.global(qos: .userInitiated).async {
            let tempDir = FileManager.default.temporaryDirectory
            let outputURL = tempDir.appendingPathComponent("animation_\(UUID().uuidString).mp4")
            try? FileManager.default.removeItem(at: outputURL)

            guard let videoWriter = try? AVAssetWriter(outputURL: outputURL, fileType: .mp4) else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "MovieExporter", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to initialize AVAssetWriter"])))
                }
                return
            }

            let width = project.width
            let height = project.height

            let videoSettings: [String: Any] = [
                AVVideoCodecKey: AVVideoCodecType.h264,
                AVVideoWidthKey: width,
                AVVideoHeightKey: height,
                AVVideoCompressionPropertiesKey: [
                    AVVideoAverageBitRateKey: 6000000,
                    AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel
                ]
            ]

            let writerInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
            writerInput.expectsMediaDataInRealTime = false

            let sourcePixelBufferAttributes: [String: Any] = [
                kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32ARGB),
                kCVPixelBufferWidthKey as String: width,
                kCVPixelBufferHeightKey as String: height
            ]

            let adaptor = AVAssetWriterInputPixelBufferAdaptor(
                assetWriterInput: writerInput,
                sourcePixelBufferAttributes: sourcePixelBufferAttributes
            )

            guard videoWriter.canAdd(writerInput) else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "MovieExporter", code: -2, userInfo: [NSLocalizedDescriptionKey: "Cannot add writer input"])))
                }
                return
            }
            videoWriter.add(writerInput)

            videoWriter.startWriting()
            videoWriter.startSession(atSourceTime: .zero)

            let fps = Int32(max(1, min(30, project.fps)))
            var frameTime = CMTime.zero
            let total = project.frames.count

            for i in 0..<total {
                let frame = project.frames[i]
                let composite = frame.renderComposite(
                    layers: project.layers,
                    canvasSize: project.canvasSize,
                    transparent: false,
                    backgroundColor: UIColor(hex: project.backgroundColorHex) ?? .white
                )

                let hold = max(1, frame.holdDuration)
                for _ in 0..<hold {
                    while !writerInput.isReadyForMoreMediaData {
                        Thread.sleep(forTimeInterval: 0.01)
                    }

                    if let pixelBuffer = newPixelBufferFrom(image: composite, size: CGSize(width: width, height: height)) {
                        adaptor.append(pixelBuffer, withPresentationTime: frameTime)
                    }
                    frameTime = CMTimeAdd(frameTime, CMTime(value: 1, timescale: fps))
                }

                DispatchQueue.main.async {
                    onProgress(i + 1, total)
                }
            }

            writerInput.markAsFinished()
            videoWriter.finishWriting {
                DispatchQueue.main.async {
                    if videoWriter.status == .completed {
                        completion(.success(outputURL))
                    } else {
                        completion(.failure(videoWriter.error ?? NSError(domain: "MovieExporter", code: -3, userInfo: [NSLocalizedDescriptionKey: "Video writer failed"])))
                    }
                }
            }
        }
    }

    // MARK: - Export Animated GIF
    public static func exportGif(
        project: Project,
        onProgress: @escaping (Int, Int) -> Void,
        completion: @escaping (Result<URL, Error>) -> Void
    ) {
        DispatchQueue.global(qos: .userInitiated).async {
            var images: [UIImage] = []
            let total = project.frames.count

            for i in 0..<total {
                let frame = project.frames[i]
                let composite = frame.renderComposite(
                    layers: project.layers,
                    canvasSize: project.canvasSize,
                    transparent: false,
                    backgroundColor: UIColor(hex: project.backgroundColorHex) ?? .white
                )
                let hold = max(1, frame.holdDuration)
                for _ in 0..<hold {
                    images.append(composite)
                }
                DispatchQueue.main.async {
                    onProgress(i + 1, total)
                }
            }

            let frameDelay = 1.0 / Double(max(1, min(30, project.fps)))
            guard let gifData = AnimatedGifEncoder.createGif(from: images, frameDelay: frameDelay) else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "MovieExporter", code: -4, userInfo: [NSLocalizedDescriptionKey: "Failed to encode GIF"])))
                }
                return
            }

            let tempDir = FileManager.default.temporaryDirectory
            let outputURL = tempDir.appendingPathComponent("animation_\(UUID().uuidString).gif")
            do {
                try gifData.write(to: outputURL)
                DispatchQueue.main.async {
                    completion(.success(outputURL))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

    // MARK: - Export PNG Sequence
    public static func exportPngSequence(
        project: Project,
        transparent: Bool,
        onProgress: @escaping (Int, Int) -> Void,
        completion: @escaping (Result<URL, Error>) -> Void
    ) {
        DispatchQueue.global(qos: .userInitiated).async {
            let tempDir = FileManager.default.temporaryDirectory
            let seqDir = tempDir.appendingPathComponent("frames_\(UUID().uuidString)")
            try? FileManager.default.createDirectory(at: seqDir, withIntermediateDirectories: true)

            let total = project.frames.count
            for i in 0..<total {
                let frame = project.frames[i]
                let composite = frame.renderComposite(
                    layers: project.layers,
                    canvasSize: project.canvasSize,
                    transparent: transparent,
                    backgroundColor: UIColor(hex: project.backgroundColorHex) ?? .white
                )

                if let data = composite.pngData() {
                    let filename = String(format: "frame_%04d.png", i + 1)
                    let fileURL = seqDir.appendingPathComponent(filename)
                    try? data.write(to: fileURL)
                }

                DispatchQueue.main.async {
                    onProgress(i + 1, total)
                }
            }

            DispatchQueue.main.async {
                completion(.success(seqDir))
            }
        }
    }

    // MARK: - Helper: CVPixelBuffer conversion
    private static func newPixelBufferFrom(image: UIImage, size: CGSize) -> CVPixelBuffer? {
        let attrs: [CFString: Any] = [
            kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue!,
            kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue!
        ]
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            Int(size.width),
            Int(size.height),
            kCVPixelFormatType_32ARGB,
            attrs as CFDictionary,
            &pixelBuffer
        )
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else { return nil }

        CVPixelBufferLockBaseAddress(buffer, [])
        let pxData = CVPixelBufferGetBaseAddress(buffer)

        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(
            data: pxData,
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
            space: rgbColorSpace,
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
        )

        if let cgImage = image.cgImage {
            context?.draw(cgImage, in: CGRect(origin: .zero, size: size))
        }

        CVPixelBufferUnlockBaseAddress(buffer, [])
        return buffer
    }
}
