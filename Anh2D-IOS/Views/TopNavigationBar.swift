import SwiftUI

public struct TopNavigationBar: View {
    @ObservedObject public var viewModel: ProjectViewModel

    public var body: some View {
        HStack(spacing: 12) {
            // Project Title & Preset
            HStack(spacing: 6) {
                Image(systemName: "film.stack.fill")
                    .foregroundColor(.flipaOrange)
                    .font(.system(size: 16, weight: .bold))

                VStack(alignment: .leading, spacing: 2) {
                    Text(viewModel.project.title)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(viewModel.project.isDarkMode ? .white : .black)
                        .lineLimit(1)

                    Text("\(viewModel.project.preset.rawValue) • \(viewModel.project.fps) FPS")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.gray)
                }
            }

            Spacer()

            // Undo / Redo
            HStack(spacing: 6) {
                Button(action: { viewModel.undo() }) {
                    Image(systemName: "arrow.uturn.backward")
                        .font(.system(size: 14, weight: .semibold))
                        .padding(8)
                        .background(viewModel.project.isDarkMode ? Color.flipaPanelElevated : Color.white)
                        .foregroundColor(viewModel.canUndo ? (viewModel.project.isDarkMode ? .white : .black) : .gray.opacity(0.5))
                        .cornerRadius(8)
                }
                .disabled(!viewModel.canUndo)

                Button(action: { viewModel.redo() }) {
                    Image(systemName: "arrow.uturn.forward")
                        .font(.system(size: 14, weight: .semibold))
                        .padding(8)
                        .background(viewModel.project.isDarkMode ? Color.flipaPanelElevated : Color.white)
                        .foregroundColor(viewModel.canRedo ? (viewModel.project.isDarkMode ? .white : .black) : .gray.opacity(0.5))
                        .cornerRadius(8)
                }
                .disabled(!viewModel.canRedo)
            }

            // Onion Skin Toggle & Settings
            HStack(spacing: 2) {
                Button(action: {
                    viewModel.isOnionSkinEnabled.toggle()
                    viewModel.drawingView.setNeedsDisplay()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "square.2.layers.3d.top.filled")
                            .font(.system(size: 12))
                        Text(viewModel.isOnionSkinEnabled ? "Onion ON" : "Onion OFF")
                            .font(.system(size: 11, weight: .bold))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(viewModel.isOnionSkinEnabled ? Color.flipaNeonGreen : (viewModel.project.isDarkMode ? Color.flipaPanelElevated : Color.white))
                    .foregroundColor(viewModel.isOnionSkinEnabled ? .black : (viewModel.project.isDarkMode ? .white : .black))
                    .cornerRadius(8)
                }

                Button(action: { viewModel.showOnionSkinSettings = true }) {
                    Image(systemName: "slider.horizontal.2.square")
                        .font(.system(size: 14))
                        .padding(6)
                        .background(viewModel.project.isDarkMode ? Color.flipaPanelElevated : Color.white)
                        .foregroundColor(viewModel.project.isDarkMode ? .white : .black)
                        .cornerRadius(8)
                }
            }

            // Canvas Settings
            Button(action: { viewModel.showCanvasSettings = true }) {
                Image(systemName: "aspectratio")
                    .font(.system(size: 14))
                    .padding(8)
                    .background(viewModel.project.isDarkMode ? Color.flipaPanelElevated : Color.white)
                    .foregroundColor(viewModel.project.isDarkMode ? .white : .black)
                    .cornerRadius(8)
            }

            // Layout Mode Switch (Classic vs Studio)
            Button(action: {
                withAnimation(.spring()) {
                    viewModel.currentLayout = (viewModel.currentLayout == .studio) ? .classic : .studio
                }
            }) {
                Text(viewModel.currentLayout == .studio ? "Studio" : "Classic")
                    .font(.system(size: 11, weight: .bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(viewModel.project.isDarkMode ? Color.flipaPanelElevated : Color.white)
                    .foregroundColor(Color.flipaOrange)
                    .cornerRadius(8)
            }

            // Theme Mode Toggle (Dark / Light)
            Button(action: {
                withAnimation {
                    viewModel.project.isDarkMode.toggle()
                    viewModel.drawingView.setNeedsDisplay()
                }
            }) {
                Image(systemName: viewModel.project.isDarkMode ? "moon.fill" : "sun.max.fill")
                    .font(.system(size: 14))
                    .padding(8)
                    .background(viewModel.project.isDarkMode ? Color.flipaPanelElevated : Color.white)
                    .foregroundColor(viewModel.project.isDarkMode ? .yellow : .orange)
                    .cornerRadius(8)
            }

            // Weekly Challenges
            Button(action: { viewModel.showChallengesDialog = true }) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 14))
                    .padding(8)
                    .background(Color.flipaYellow)
                    .foregroundColor(.black)
                    .cornerRadius(8)
            }

            // Layers Drawer Toggle
            Button(action: {
                withAnimation(.spring()) {
                    viewModel.showLayerDrawer.toggle()
                }
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "square.3.layers.3d.down.right")
                        .font(.system(size: 13))
                    Text("Lớp (\(viewModel.project.layers.count))")
                        .font(.system(size: 11, weight: .bold))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.flipaPanelElevated)
                .foregroundColor(.white)
                .cornerRadius(8)
            }

            // Export Movie Button
            Button(action: { viewModel.showExportSheet = true }) {
                HStack(spacing: 4) {
                    Image(systemName: "square.and.arrow.up.fill")
                        .font(.system(size: 12))
                    Text("Xuất")
                        .font(.system(size: 12, weight: .bold))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.flipaOrange)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(viewModel.project.isDarkMode ? Color.flipaPanelDark : Color(hex: "#F1F5F9"))
        .shadow(color: Color.black.opacity(0.15), radius: 4, y: 2)
    }
}
