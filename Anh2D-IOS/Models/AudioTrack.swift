import Foundation

public struct AudioTrack: Identifiable, Equatable {
    public var id: UUID
    public var name: String
    public var fileURL: URL?
    public var startFrame: Int
    public var durationFrames: Int
    public var volume: Float
    public var isMuted: Bool
    public var waveformAmplitudes: [Float]

    public init(
        id: UUID = UUID(),
        name: String = "Track 1",
        fileURL: URL? = nil,
        startFrame: Int = 0,
        durationFrames: Int = 24,
        volume: Float = 1.0,
        isMuted: Bool = false,
        waveformAmplitudes: [Float] = []
    ) {
        self.id = id
        self.name = name
        self.fileURL = fileURL
        self.startFrame = startFrame
        self.durationFrames = durationFrames
        self.volume = volume
        self.isMuted = isMuted
        self.waveformAmplitudes = waveformAmplitudes
    }
}
