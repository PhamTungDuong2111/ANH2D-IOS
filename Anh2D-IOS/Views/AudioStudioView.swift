import SwiftUI

public struct AudioStudioView: View {
    @ObservedObject public var viewModel: ProjectViewModel

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Header
            HStack {
                Image(systemName: "waveform")
                    .foregroundColor(Color.flipaCyan)
                Text("Studio Âm Thanh Đa Tầng (\(viewModel.project.audioTracks.count)/6)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(viewModel.project.isDarkMode ? .white : .black)

                Spacer()

                Button(action: { viewModel.addAudioTrack() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                        Text("Thêm Dải Âm")
                    }
                    .font(.system(size: 11, weight: .bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.flipaCyan)
                    .foregroundColor(.black)
                    .cornerRadius(6)
                }
            }
            .padding(.horizontal, 12)

            // Tracks list
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(viewModel.project.audioTracks) { track in
                        audioTrackCard(for: track)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 6)
            }
        }
        .padding(.vertical, 6)
        .background(viewModel.project.isDarkMode ? Color.flipaPanelElevated.opacity(0.85) : Color.white.opacity(0.9))
        .cornerRadius(12)
        .padding(.horizontal, 12)
    }

    private func audioTrackCard(for track: AudioTrack) -> some View {
        let isRecording = (viewModel.recordingTrackId == track.id)

        return VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(track.name)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(viewModel.project.isDarkMode ? .white : .black)
                    .lineLimit(1)

                Spacer()

                // Mute toggle
                Button(action: {
                    if let idx = viewModel.project.audioTracks.firstIndex(where: { $0.id == track.id }) {
                        viewModel.project.audioTracks[idx].isMuted.toggle()
                    }
                }) {
                    Image(systemName: track.isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                        .font(.system(size: 11))
                        .foregroundColor(track.isMuted ? .gray : Color.flipaOrange)
                }
            }

            // Waveform visualizer
            HStack(spacing: 2) {
                if track.waveformAmplitudes.isEmpty {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 2)
                } else {
                    ForEach(0..<min(24, track.waveformAmplitudes.count), id: \.self) { i in
                        let amp = CGFloat(track.waveformAmplitudes[i])
                        RoundedRectangle(cornerRadius: 1)
                            .fill(Color.flipaCyan)
                            .frame(width: 3, height: max(4, amp * 20))
                    }
                }
            }
            .frame(height: 22)
            .frame(maxWidth: .infinity)
            .background(Color.black.opacity(0.2))
            .cornerRadius(4)

            // Action buttons
            HStack(spacing: 6) {
                // Mic Record
                Button(action: {
                    viewModel.toggleVoiceRecording(for: track)
                }) {
                    HStack(spacing: 3) {
                        Image(systemName: isRecording ? "stop.circle.fill" : "mic.fill")
                        Text(isRecording ? "DỪNG" : "Ghi Mic")
                    }
                    .font(.system(size: 10, weight: .bold))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 4)
                    .background(isRecording ? Color.flipaYellow : Color.flipaRed)
                    .foregroundColor(isRecording ? .black : .white)
                    .cornerRadius(6)
                }

                // AI Voice Maker
                Button(action: {
                    viewModel.activeAiVoiceTrack = track
                    viewModel.showAiVoicePrompt = true
                }) {
                    HStack(spacing: 2) {
                        Image(systemName: "sparkles")
                        Text("AI Voice")
                    }
                    .font(.system(size: 10, weight: .bold))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 4)
                    .background(Color.flipaCyan)
                    .foregroundColor(.black)
                    .cornerRadius(6)
                }
            }
        }
        .padding(8)
        .frame(width: 175)
        .background(viewModel.project.isDarkMode ? Color.flipaPanelDark : Color(hex: "#F1F5F9"))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isRecording ? Color.flipaRed : Color.gray.opacity(0.2), lineWidth: isRecording ? 2 : 1)
        )
    }
}
