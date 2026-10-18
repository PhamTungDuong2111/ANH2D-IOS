import Foundation
import AVFoundation

public final class AiVoiceMaker: NSObject {
    private let synthesizer = AVSpeechSynthesizer()

    public func generateSpeech(
        text: String,
        into track: inout AudioTrack,
        language: String = "vi-VN",
        completion: @escaping (Result<URL, Error>) -> Void
    ) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language) ?? AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        utterance.pitchMultiplier = 1.0

        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = docs.appendingPathComponent("aivoice_\(track.id.uuidString).caf")

        var outputAudioFile: AVAudioFile?

        synthesizer.write(utterance) { buffer in
            guard let pcmBuffer = buffer as? AVAudioPCMBuffer else { return }

            if pcmBuffer.frameLength == 0 {
                // Done writing
                return
            }

            if outputAudioFile == nil {
                do {
                    outputAudioFile = try AVAudioFile(
                        forWriting: fileURL,
                        settings: pcmBuffer.format.settings,
                        commonFormat: .pcmFormatInt16,
                        interleaved: false
                    )
                } catch {
                    print("Error creating audio file for speech: \(error.localizedDescription)")
                }
            }

            try? outputAudioFile?.write(from: pcmBuffer)
        }

        // Delay briefly to allow synth buffers to flush and populate track
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            track.fileURL = fileURL
            track.waveformAmplitudes = (0..<30).map { _ in Float.random(in: 0.3...0.9) }
            completion(.success(fileURL))
        }
    }
}
