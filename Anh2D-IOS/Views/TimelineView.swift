import SwiftUI

public struct TimelineView: View {
    @ObservedObject public var viewModel: ProjectViewModel

    public var body: some View {
        VStack(spacing: 8) {
            // Control Buttons Row
            HStack(spacing: 12) {
                // Play / Pause
                Button(action: {
                    viewModel.timelineManager.togglePlayback()
                }) {
                    Image(systemName: viewModel.timelineManager.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 16, weight: .bold))
                        .frame(width: 44, height: 36)
                        .background(Color.flipaOrange)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }

                // Step Prev
                Button(action: { viewModel.timelineManager.stepPrevFrame() }) {
                    Image(systemName: "backward.end.fill")
                        .font(.system(size: 14))
                        .frame(width: 36, height: 36)
                        .background(viewModel.project.isDarkMode ? Color.flipaPanelElevated : Color.white)
                        .foregroundColor(viewModel.project.isDarkMode ? .white : .black)
                        .cornerRadius(8)
                }

                // Step Next
                Button(action: { viewModel.timelineManager.stepNextFrame() }) {
                    Image(systemName: "forward.end.fill")
                        .font(.system(size: 14))
                        .frame(width: 36, height: 36)
                        .background(viewModel.project.isDarkMode ? Color.flipaPanelElevated : Color.white)
                        .foregroundColor(viewModel.project.isDarkMode ? .white : .black)
                        .cornerRadius(8)
                }

                // Frame Counter
                Text("\(viewModel.project.currentFrameIndex + 1) / \(viewModel.project.frames.count)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(viewModel.project.isDarkMode ? .white : .black)
                    .frame(minWidth: 55)

                Spacer()

                // Add Frame (+)
                Button(action: { viewModel.timelineManager.addFrame() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                        Text("Frame")
                    }
                    .font(.system(size: 12, weight: .bold))
                    .padding(.horizontal, 10)
                    .frame(height: 36)
                    .background(Color.flipaNeonGreen)
                    .foregroundColor(.black)
                    .cornerRadius(8)
                }

                // Duplicate Frame
                Button(action: { viewModel.timelineManager.duplicateCurrentFrame() }) {
                    Image(systemName: "doc.on.doc.fill")
                        .font(.system(size: 13))
                        .frame(width: 36, height: 36)
                        .background(viewModel.project.isDarkMode ? Color.flipaPanelElevated : Color.white)
                        .foregroundColor(viewModel.project.isDarkMode ? .white : .black)
                        .cornerRadius(8)
                }

                // Hold Duration (1x..5x)
                Button(action: {
                    if let f = viewModel.project.currentFrame {
                        let next = (f.holdDuration >= 5) ? 1 : f.holdDuration + 1
                        viewModel.timelineManager.setHoldDuration(next)
                    }
                }) {
                    Text("Hold \(viewModel.project.currentFrame?.holdDuration ?? 1)x")
                        .font(.system(size: 11, weight: .bold))
                        .padding(.horizontal, 8)
                        .frame(height: 36)
                        .background(viewModel.project.isDarkMode ? Color.flipaPanelElevated : Color.white)
                        .foregroundColor(Color.flipaYellow)
                        .cornerRadius(8)
                }

                // Loop Sequence
                Button(action: { viewModel.showLoopSequenceDialog = true }) {
                    Image(systemName: "repeat")
                        .font(.system(size: 13, weight: .bold))
                        .frame(width: 36, height: 36)
                        .background(viewModel.project.isDarkMode ? Color.flipaPanelElevated : Color.white)
                        .foregroundColor(Color.flipaCyan)
                        .cornerRadius(8)
                }

                // Delete Frame
                Button(action: {
                    if !viewModel.timelineManager.deleteCurrentFrame() {
                        viewModel.showToast("Không thể xóa khung hình duy nhất")
                    }
                }) {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 13))
                        .frame(width: 36, height: 36)
                        .background(Color.flipaRed.opacity(0.85))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal, 12)

            // Horizontal Frame Scrubber Thumbnails
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
                                ZStack(alignment: .bottomTrailing) {
                                    Image(uiImage: FrameThumbnailRenderer.renderThumbnail(for: frame, project: viewModel.project))
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 76, height: 48)
                                        .background(Color.white)
                                        .cornerRadius(6)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 6)
                                                .stroke(isSelected ? Color.flipaOrange : Color.gray.opacity(0.4), lineWidth: isSelected ? 3 : 1)
                                        )

                                    // Frame Index badge
                                    Text("\(idx + 1)")
                                        .font(.system(size: 9, weight: .bold))
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 2)
                                        .background(Color.black.opacity(0.75))
                                        .foregroundColor(.white)
                                        .cornerRadius(4)
                                        .padding(2)

                                    if frame.holdDuration > 1 {
                                        Text("\(frame.holdDuration)x")
                                            .font(.system(size: 9, weight: .bold))
                                            .padding(.horizontal, 3)
                                            .padding(.vertical, 1)
                                            .background(Color.flipaYellow)
                                            .foregroundColor(.black)
                                            .cornerRadius(3)
                                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                            .padding(2)
                                    }
                                }
                            }
                            .id(idx)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                }
                .onChange(of: viewModel.project.currentFrameIndex) { newIndex in
                    withAnimation {
                        proxy.scrollTo(newIndex, anchor: .center)
                    }
                }
            }
        }
        .padding(.vertical, 8)
        .background(viewModel.project.isDarkMode ? Color.flipaPanelDark : Color(hex: "#F1F5F9"))
        .shadow(color: Color.black.opacity(0.15), radius: 4, y: -2)
    }
}
