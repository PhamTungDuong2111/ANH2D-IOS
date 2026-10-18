import Foundation
import AVFoundation

public final class AudioEngine: NSObject, AVAudioRecorderDelegate {
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayers: [UUID: AVAudioPlayer] = [:]

    public var isRecording: Bool {
        audioRecorder?.isRecording ?? false
    }

    public override init() {
        super.init()
        setupAudioSession()
    }

    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
            try session.setActive(true)
        } catch {
            print("Failed to configure AVAudioSession: \(error.localizedDescription)")
        }
    }

    // MARK: - Voiceover Recording
    public func startRecording(
        for track: AudioTrack,
        completion: @escaping (Result<URL, Error>) -> Void
    ) {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = docs.appendingPathComponent("voiceover_\(track.id.uuidString).m4a")

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            completion(.success(fileURL))
        } catch {
            completion(.failure(error))
        }
    }

    public func stopRecording(for track: inout AudioTrack) -> URL? {
        guard let recorder = audioRecorder, recorder.isRecording else { return nil }
        let url = recorder.url
        recorder.stop()
        audioRecorder = nil

        track.fileURL = url
        track.waveformAmplitudes = generateWaveform(from: url)
        return url
    }

    // MARK: - Audio Import
    public func importAudioFile(from sourceURL: URL, into track: inout AudioTrack) -> Bool {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let destURL = docs.appendingPathComponent("imported_\(track.id.uuidString).\(sourceURL.pathExtension)")

        do {
            if FileManager.default.fileExists(atPath: destURL.path) {
                try FileManager.default.removeItem(at: destURL)
            }
            try FileManager.default.copyItem(at: sourceURL, to: destURL)
            track.fileURL = destURL
            track.waveformAmplitudes = generateWaveform(from: destURL)
            return true
        } catch {
            print("Error importing audio: \(error.localizedDescription)")
            return false
        }
    }

    // MARK: - Playback
    public func playTrack(_ track: AudioTrack) {
        guard !track.isMuted, let url = track.fileURL else { return }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = track.volume
            player.play()
            audioPlayers[track.id] = player
        } catch {
            print("Error playing audio track: \(error.localizedDescription)")
        }
    }

    public func stopAllTracks() {
        for player in audioPlayers.values {
            player.stop()
        }
        audioPlayers.removeAll()
    }

    // MARK: - Waveform Generator
    private func generateWaveform(from url: URL, sampleCount: Int = 40) -> [Float] {
        guard let file = try? AVAudioFile(forReading: url) else {
            return (0..<sampleCount).map { _ in Float.random(in: 0.2...0.8) }
        }

        let format = file.processingFormat
        let frameCount = UInt32(file.length)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            return (0..<sampleCount).map { _ in Float.random(in: 0.2...0.8) }
        }

        do {
            try file.read(into: buffer)
        } catch {
            return (0..<sampleCount).map { _ in Float.random(in: 0.2...0.8) }
        }

        guard let channelData = buffer.floatChannelData?[0] else {
            return (0..<sampleCount).map { _ in Float.random(in: 0.2...0.8) }
        }

        let step = Int(frameCount) / sampleCount
        guard step > 0 else { return [] }

        var amplitudes: [Float] = []
        for i in 0..<sampleCount {
            var sum: Float = 0
            for j in 0..<step {
                sum += abs(channelData[i * step + j])
            }
            let avg = sum / Float(step)
            amplitudes.append(min(1.0, avg * 3.0))
        }
        return amplitudes
    }
}
