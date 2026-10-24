import SwiftUI

public struct TimelineView: View {
    @ObservedObject public var viewModel: ProjectViewModel
    @ObservedObject private var loc = LocalizationManager.shared

    public var body: some View {
        VStack(spacing: 0) {
            // Audio Waveform Bar (matching ADR .timeline-audio-bar)
            if hasActiveAudio {
                HStack(spacing: 8) {
                    Image(systemName: "waveform")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color.flipaCyan)

                    Text(loc.t("audio_track"))
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Color.flipaCyan)

                    // Simulated live waveform strip
                    GeometryReader { geo in
                        Path { path in
                            let mid = geo.size.height / 2
                            let w = geo.size.width
                            var x: CGFloat = 0
                            path.move(to: CGPoint(x: 0, y: mid))
                            while x < w {
                                let amp = sin(x * 0.15) * 6
                                path.addLine(to: CGPoint(x: x, y: mid + amp))
                                x += 4
                            }
                        }
                        .stroke(Color.flipaCyan.opacity(0.8), lineWidth: 1.5)
                    }
                    .frame(height: 16)
                }
                .padding(.horizontal, 14)
                .frame(height: 24)
                .background(Color.flipaDarkBg.opacity(0.85))
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(viewModel.project.isDarkMode ? Color.flipaBorder : Color.black.opacity(0.08)),
                    alignment: .top
                )
            }

            // Main Timeline Row (Playback Controls + Filmstrip + Actions)
            HStack(spacing: 10) {
                // PLAYBACK CONTROLS (matching ADR .playback-cluster)
                HStack(spacing: 6) {
                    // Main Play/Pause Button (48x48 rounded gradient coral)
                    Button(action: {
                        viewModel.timelineManager.togglePlayback()
                    }) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(
                                    colors: [Color.flipaCoral, Color(hex: "#FF3B30")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .frame(width: 44, height: 44)
                                .shadow(color: Color.flipaCoral.opacity(0.4), radius: 6, y: 2)

                            Image(systemName: viewModel.timelineManager.isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .offset(x: viewModel.timelineManager.isPlaying ? 0 : 1.5)
                        }
                    }

                    // Loop Toggle
                    Button(action: {
                        viewModel.timelineManager.isLooping.toggle()
                    }) {
                        Image(systemName: "repeat")
                            .font(.system(size: 13, weight: .bold))
                            .frame(width: 32, height: 32)
                            .background(viewModel.timelineManager.isLooping ? Color.flipaCoral : (viewModel.project.isDarkMode ? Color.flipaPanelElevated : Color.white))
                            .foregroundColor(viewModel.timelineManager.isLooping ? .white : (viewModel.project.isDarkMode ? .white : .black))
                            .cornerRadius(8)
                    }

                    // Onion Skin Toggle
                    Button(action: {
                        viewModel.isOnionSkinEnabled.toggle()
                        viewModel.drawingView.isOnionSkinEnabled = viewModel.isOnionSkinEnabled
                        viewModel.drawingView.setNeedsDisplay()
                    }) {
                        Image(systemName: "square.2.layers.3d.top.filled")
                            .font(.system(size: 13, weight: .bold))
                            .frame(width: 32, height: 32)
                            .background(viewModel.isOnionSkinEnabled ? Color.flipaCoral : (viewModel.project.isDarkMode ? Color.flipaPanelElevated : Color.white))
                            .foregroundColor(viewModel.isOnionSkinEnabled ? .white : (viewModel.project.isDarkMode ? .white : .black))
                            .cornerRadius(8)
                    }

                    // FPS Badge Button
                    Button(action: {
                        viewModel.showFpsModal = true
                    }) {
                        Text("\(viewModel.project.fps) FPS")
                            .font(.system(size: 11, weight: .black, design: .monospaced))
                            .padding(.horizontal, 7)
                            .frame(height: 32)
                            .background(viewModel.project.isDarkMode ? Color.flipaPanelElevated : Color.white)
                            .foregroundColor(viewModel.project.isDarkMode ? .white : .black)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                }

                // FILMSTRIP FRAME STRIP (matching ADR .filmstrip-container)
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(0..<viewModel.project.frames.count, id: \.self) { idx in
                                let isSelected = (idx == viewModel.project.currentFrameIndex)
                                let frame = viewModel.project.frames[idx]

                                Button(action: {
                                    viewModel.project.currentFrameIndex = idx
                                    viewModel.drawingView.setNeedsDisplay()
                                }) {
                                    ZStack(alignment: .bottomLeading) {
                                        // Frame Thumbnail Image
                                        Image(uiImage: FrameThumbnailRenderer.renderThumbnail(for: frame, project: viewModel.project))
                                            .resizable()
                                            .aspectRatio(16/9, contentMode: .fit)
                                            .frame(width: 76, height: 48)
                                            .background(Color.white)
                                            .cornerRadius(6)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 6)
                                                    .stroke(isSelected ? Color.flipaCoral : Color.gray.opacity(0.3), lineWidth: isSelected ? 2.5 : 1)
                                            )
                                            .shadow(color: isSelected ? Color.flipaCoral.opacity(0.35) : Color.clear, radius: 4)

                                        // Frame Number Badge (bottom left, matching ADR)
                                        Text("\(idx + 1)")
                                            .font(.system(size: 9, weight: .black, design: .monospaced))
                                            .padding(.horizontal, 4)
                                            .padding(.vertical, 1)
                                            .background(Color.black.opacity(0.75))
                                            .foregroundColor(.white)
                                            .cornerRadius(3)
                                            .padding(3)
                                    }
                                }
                                .id(idx)
                            }

                            // Add Frame (+) Card (matching ADR .frame-add-card)
                            Button(action: {
                                viewModel.timelineManager.addFrame()
                            }) {
                                VStack(spacing: 2) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 16, weight: .bold))
                                }
                                .frame(width: 44, height: 48)
                                .background(viewModel.project.isDarkMode ? Color.flipaPanelElevated : Color.white)
                                .foregroundColor(Color.flipaCoral)
                                .cornerRadius(6)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [4]))
                                        .foregroundColor(Color.flipaCoral.opacity(0.6))
                                )
                            }
                        }
                        .padding(.vertical, 6)
                        .padding(.horizontal, 4)
                    }
                    .onChange(of: viewModel.project.currentFrameIndex) { newIdx in
                        withAnimation {
                            proxy.scrollTo(newIdx, anchor: .center)
                        }
                    }
                }

                // FRAME ACTIONS CLUSTER (matching ADR .frame-actions-cluster)
                HStack(spacing: 4) {
                    // Duplicate Frame
                    Button(action: {
                        viewModel.timelineManager.duplicateCurrentFrame()
                    }) {
                        Image(systemName: "doc.on.doc")
                            .font(.system(size: 12, weight: .semibold))
                            .frame(width: 32, height: 32)
                            .background(viewModel.project.isDarkMode ? Color.flipaPanelElevated : Color.white)
                            .foregroundColor(viewModel.project.isDarkMode ? .white : .black)
                            .cornerRadius(8)
                    }

                    // Copy Frame
                    Button(action: {
                        viewModel.copyCurrentFrame()
                    }) {
                        Image(systemName: "doc.on.clipboard")
                            .font(.system(size: 12, weight: .semibold))
                            .frame(width: 32, height: 32)
                            .background(viewModel.project.isDarkMode ? Color.flipaPanelElevated : Color.white)
                            .foregroundColor(viewModel.project.isDarkMode ? .white : .black)
                            .cornerRadius(8)
                    }

                    // Paste Frame
                    Button(action: {
                        viewModel.pasteFrame()
                    }) {
                        Image(systemName: "arrow.right.doc.on.clipboard")
                            .font(.system(size: 12, weight: .semibold))
                            .frame(width: 32, height: 32)
                            .background(viewModel.project.isDarkMode ? Color.flipaPanelElevated : Color.white)
                            .foregroundColor(viewModel.timelineManager.copiedFrame != nil ? Color.flipaCoral : .gray.opacity(0.4))
                            .cornerRadius(8)
                    }
                    .disabled(viewModel.timelineManager.copiedFrame == nil)

                    // Delete Frame
                    Button(action: {
                        if !viewModel.timelineManager.deleteCurrentFrame() {
                            viewModel.showToast(loc.t("cant_delete_single_frame"))
                        }
                    }) {
                        Image(systemName: "trash")
                            .font(.system(size: 12, weight: .semibold))
                            .frame(width: 32, height: 32)
                            .background(viewModel.project.isDarkMode ? Color.flipaPanelElevated : Color.white)
                            .foregroundColor(Color.flipaRed)
                            .cornerRadius(8)
                    }
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(viewModel.project.isDarkMode ? Color.flipaSurface : Color(hex: "#F1F5F9"))
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(viewModel.project.isDarkMode ? Color.flipaBorder : Color.black.opacity(0.08)),
                alignment: .top
            )
        }
    }

    private var hasActiveAudio: Bool {
        viewModel.project.audioTracks.contains(where: { $0.fileURL != nil })
    }
}
