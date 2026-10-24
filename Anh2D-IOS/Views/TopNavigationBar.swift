import SwiftUI

public struct TopNavigationBar: View {
    @ObservedObject public var viewModel: ProjectViewModel
    @ObservedObject private var loc = LocalizationManager.shared

    public var body: some View {
        HStack(spacing: 8) {
            // LEFT: Brand Button with 'F' and Project Name
            Button(action: {
                withAnimation(.spring()) {
                    viewModel.showProjectsGallery = true
                }
            }) {
                HStack(spacing: 8) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(LinearGradient(
                                colors: [Color.flipaCoral, Color(hex: "#FF3B30")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 34, height: 34)
                            .shadow(color: Color.flipaCoral.opacity(0.3), radius: 4, y: 2)

                        Text("F")
                            .font(.system(size: 20, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(viewModel.project.title)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(viewModel.project.isDarkMode ? .white : .black)
                            .lineLimit(1)

                        Text("\(viewModel.project.width)x\(viewModel.project.height) • \(viewModel.project.fps) FPS")
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                            .foregroundColor(.gray)
                    }

                    Image(systemName: "chevron.down")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 4)
                .background(viewModel.project.isDarkMode ? Color.flipaPanelElevated.opacity(0.5) : Color.white.opacity(0.6))
                .cornerRadius(10)
            }

            Spacer()

            // CENTER: Tool Action Buttons (Undo, Redo, Ruler, Lasso, Eyedropper)
            HStack(spacing: 6) {
                // Undo
                Button(action: { viewModel.undo() }) {
                    Image(systemName: "arrow.uturn.backward")
                        .font(.system(size: 13, weight: .semibold))
                        .frame(width: 34, height: 34)
                        .background(viewModel.project.isDarkMode ? Color.flipaPanelElevated : Color.white)
                        .foregroundColor(viewModel.canUndo ? (viewModel.project.isDarkMode ? .white : .black) : .gray.opacity(0.4))
                        .cornerRadius(8)
                }
                .disabled(!viewModel.canUndo)

                // Redo
                Button(action: { viewModel.redo() }) {
                    Image(systemName: "arrow.uturn.forward")
                        .font(.system(size: 13, weight: .semibold))
                        .frame(width: 34, height: 34)
                        .background(viewModel.project.isDarkMode ? Color.flipaPanelElevated : Color.white)
                        .foregroundColor(viewModel.canRedo ? (viewModel.project.isDarkMode ? .white : .black) : .gray.opacity(0.4))
                        .cornerRadius(8)
                }
                .disabled(!viewModel.canRedo)

                // Ruler
                Button(action: { viewModel.cycleRuler() }) {
                    Image(systemName: viewModel.rulerType.iconName)
                        .font(.system(size: 14, weight: .semibold))
                        .frame(width: 34, height: 34)
                        .background(viewModel.rulerType != .none ? Color.flipaCoral : (viewModel.project.isDarkMode ? Color.flipaPanelElevated : Color.white))
                        .foregroundColor(viewModel.rulerType != .none ? .white : (viewModel.project.isDarkMode ? .white : .black))
                        .cornerRadius(8)
                }

                // Lasso Tool
                Button(action: {
                    if viewModel.currentTool == .lasso {
                        viewModel.currentTool = .pen
                    } else {
                        viewModel.selectTool(.lasso)
                    }
                }) {
                    Image(systemName: "lasso")
                        .font(.system(size: 14, weight: .semibold))
                        .frame(width: 34, height: 34)
                        .background(viewModel.currentTool == .lasso ? Color.flipaCoral : (viewModel.project.isDarkMode ? Color.flipaPanelElevated : Color.white))
                        .foregroundColor(viewModel.currentTool == .lasso ? .white : (viewModel.project.isDarkMode ? .white : .black))
                        .cornerRadius(8)
                }

                // Eyedropper
                Button(action: { viewModel.toggleEyedropper() }) {
                    Image(systemName: "eyedropper.halffull")
                        .font(.system(size: 13, weight: .semibold))
                        .frame(width: 34, height: 34)
                        .background(viewModel.currentTool == .eyedropper ? Color.flipaCoral : (viewModel.project.isDarkMode ? Color.flipaPanelElevated : Color.white))
                        .foregroundColor(viewModel.currentTool == .eyedropper ? .white : (viewModel.project.isDarkMode ? .white : .black))
                        .cornerRadius(8)
                }
            }

            Spacer()

            // RIGHT: Language, Layers Badge, Audio, Settings, Make Movie CTA
            HStack(spacing: 6) {
                // Language Switcher Badge Button
                Button(action: {
                    withAnimation {
                        loc.toggleLanguage()
                    }
                }) {
                    HStack(spacing: 3) {
                        Text(loc.currentLanguage.flag)
                            .font(.system(size: 12))
                        Text(loc.currentLanguage.shortCode)
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(viewModel.project.isDarkMode ? .white : .black)
                    }
                    .frame(height: 34)
                    .padding(.horizontal, 8)
                    .background(viewModel.project.isDarkMode ? Color.flipaPanelElevated : Color.white)
                    .cornerRadius(8)
                }

                // Layers Drawer Toggle with Badge
                Button(action: {
                    withAnimation(.spring()) {
                        viewModel.showLayerDrawer.toggle()
                    }
                }) {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "square.3.layers.3d.down.right")
                            .font(.system(size: 14, weight: .semibold))
                            .frame(width: 34, height: 34)
                            .background(viewModel.showLayerDrawer ? Color.flipaCoral : (viewModel.project.isDarkMode ? Color.flipaPanelElevated : Color.white))
                            .foregroundColor(viewModel.showLayerDrawer ? .white : (viewModel.project.isDarkMode ? .white : .black))
                            .cornerRadius(8)

                        // Layers count badge
                        Text("\(viewModel.project.layers.count)")
                            .font(.system(size: 9, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(width: 15, height: 15)
                            .background(Color.flipaCoral)
                            .clipShape(Circle())
                            .offset(x: 4, y: -4)
                    }
                }

                // Audio Modal Button
                Button(action: {
                    viewModel.showAudioModal = true
                }) {
                    Image(systemName: "waveform")
                        .font(.system(size: 14, weight: .semibold))
                        .frame(width: 34, height: 34)
                        .background(viewModel.project.isDarkMode ? Color.flipaPanelElevated : Color.white)
                        .foregroundColor(viewModel.project.isDarkMode ? .white : .black)
                        .cornerRadius(8)
                }

                // Settings Modal Button
                Button(action: {
                    viewModel.showSettingsModal = true
                }) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .frame(width: 34, height: 34)
                        .background(viewModel.project.isDarkMode ? Color.flipaPanelElevated : Color.white)
                        .foregroundColor(viewModel.project.isDarkMode ? .white : .black)
                        .cornerRadius(8)
                }

                // "Tạo phim" / Make Movie Prominent CTA Button
                Button(action: { viewModel.showExportSheet = true }) {
                    HStack(spacing: 5) {
                        Image(systemName: "film.fill")
                            .font(.system(size: 12, weight: .bold))
                        Text(loc.t("make_movie"))
                            .font(.system(size: 12, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(height: 34)
                    .padding(.horizontal, 12)
                    .background(LinearGradient(
                        colors: [Color.flipaCoral, Color(hex: "#FF3B30")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .cornerRadius(8)
                    .shadow(color: Color.flipaCoral.opacity(0.35), radius: 6, y: 2)
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(viewModel.project.isDarkMode ? Color.flipaSurface : Color(hex: "#F1F5F9"))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(viewModel.project.isDarkMode ? Color.flipaBorder : Color.black.opacity(0.08)),
            alignment: .bottom
        )
    }
}
