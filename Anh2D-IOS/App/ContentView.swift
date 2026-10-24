import SwiftUI

public struct ContentView: View {
    @StateObject private var viewModel = ProjectViewModel()

    public var body: some View {
        ZStack {
            // Workspace Background
            (viewModel.project.isDarkMode ? Color.flipaDarkBg : Color(hex: "#E2E8F0"))
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top Navigation Bar (matching ADR Header)
                TopNavigationBar(viewModel: viewModel)

                // Central Workspace Area
                ZStack(alignment: .leading) {
                    // Native Canvas Stage
                    CanvasViewRepresentable(
                        project: viewModel.project,
                        currentTool: $viewModel.currentTool,
                        currentShape: $viewModel.currentShape,
                        brushColor: $viewModel.brushColor,
                        brushSize: $viewModel.brushSize,
                        brushOpacity: $viewModel.brushOpacity,
                        isOnionSkinEnabled: $viewModel.isOnionSkinEnabled,
                        isGridVisible: $viewModel.isGridVisible,
                        rulerType: $viewModel.rulerType,
                        drawingView: viewModel.drawingView
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                    // STAGE FLOATING CONTROLS: Top-Right (Zoom Fit & Grid Toggle, matching ADR)
                    VStack {
                        HStack {
                            Spacer()
                            HStack(spacing: 8) {
                                Button(action: {
                                    viewModel.zoomFit()
                                }) {
                                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                                        .font(.system(size: 13, weight: .bold))
                                        .frame(width: 34, height: 34)
                                        .background(viewModel.project.isDarkMode ? Color.flipaPanelElevated.opacity(0.85) : Color.white.opacity(0.85))
                                        .foregroundColor(viewModel.project.isDarkMode ? .white : .black)
                                        .cornerRadius(8)
                                        .shadow(color: Color.black.opacity(0.15), radius: 4)
                                }

                                Button(action: {
                                    viewModel.toggleGrid()
                                }) {
                                    Image(systemName: viewModel.isGridVisible ? "square.grid.3x3.fill" : "square.grid.3x3")
                                        .font(.system(size: 13, weight: .bold))
                                        .frame(width: 34, height: 34)
                                        .background(viewModel.isGridVisible ? Color.flipaCoral : (viewModel.project.isDarkMode ? Color.flipaPanelElevated.opacity(0.85) : Color.white.opacity(0.85)))
                                        .foregroundColor(viewModel.isGridVisible ? .white : (viewModel.project.isDarkMode ? .white : .black))
                                        .cornerRadius(8)
                                        .shadow(color: Color.black.opacity(0.15), radius: 4)
                                }
                            }
                            .padding(.top, 12)
                            .padding(.trailing, 12)
                        }
                        Spacer()
                    }

                    // FLOATING TOOL DOCK: Left side (matching ADR #tools-dock)
                    ToolDockView(viewModel: viewModel)
                        .padding(.leading, 10)

                    // LASSO FLOATING BAR: Bottom-Right (matching ADR #lasso-bar)
                    if viewModel.drawingView.lassoManager.hasSelection {
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                HStack(spacing: 8) {
                                    Button(action: { viewModel.lassoFlipH() }) {
                                        Image(systemName: "arrow.left.and.right.righttriangle.left.righttriangle.right")
                                            .font(.system(size: 13, weight: .bold))
                                            .frame(width: 36, height: 36)
                                            .background(viewModel.project.isDarkMode ? Color.flipaPanelElevated : Color.white)
                                            .foregroundColor(viewModel.project.isDarkMode ? .white : .black)
                                            .cornerRadius(8)
                                    }

                                    Button(action: { viewModel.lassoDelete() }) {
                                        Image(systemName: "trash.fill")
                                            .font(.system(size: 13, weight: .bold))
                                            .frame(width: 36, height: 36)
                                            .background(viewModel.project.isDarkMode ? Color.flipaPanelElevated : Color.white)
                                            .foregroundColor(Color.flipaRed)
                                            .cornerRadius(8)
                                    }

                                    Button(action: { viewModel.lassoDone() }) {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 13, weight: .bold))
                                            .frame(width: 36, height: 36)
                                            .background(Color.flipaGreen)
                                            .foregroundColor(.white)
                                            .cornerRadius(8)
                                    }
                                }
                                .padding(6)
                                .background(viewModel.project.isDarkMode ? Color.flipaSurface.opacity(0.95) : Color(hex: "#F8FAFC").opacity(0.95))
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.25), radius: 8, y: 2)
                                .padding(.bottom, 12)
                                .padding(.trailing, 12)
                            }
                        }
                    }
                }

                // Studio Mode Audio Section (if enabled)
                if viewModel.currentLayout == .studio {
                    AudioStudioView(viewModel: viewModel)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                // Bottom Animation Timeline (matching ADR #app-bottom-timeline)
                TimelineView(viewModel: viewModel)
            }

            // Slide-over Right Layers Drawer
            if viewModel.showLayerDrawer {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring()) {
                            viewModel.showLayerDrawer = false
                        }
                    }

                HStack {
                    Spacer()
                    LayerDrawerView(viewModel: viewModel)
                        .transition(.move(edge: .trailing))
                }
                .ignoresSafeArea(edges: .vertical)
            }

            // Toast Alert Banner
            if let toast = viewModel.toastMessage {
                VStack {
                    Text(toast)
                        .font(.system(size: 13, weight: .bold))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.flipaPanelDark.opacity(0.95))
                        .foregroundColor(.white)
                        .cornerRadius(20)
                        .shadow(radius: 6)
                        .padding(.top, 50)
                    Spacer()
                }
                .transition(.move(edge: .top).combined(with: .opacity))
                .animation(.easeInOut, value: viewModel.toastMessage)
            }
        }
        .preferredColorScheme(viewModel.project.isDarkMode ? .dark : .light)
        .sheet(isPresented: $viewModel.showProjectsGallery) {
            ProjectsGallerySheet(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showNewProjectSheet) {
            NewProjectSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showAudioModal) {
            AudioModalSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showSettingsModal) {
            SettingsModalSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showFpsModal) {
            FpsModalSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showExportSheet) {
            ExportSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showCanvasSettings) {
            CanvasSettingsSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showChallengesDialog) {
            ChallengesDialog(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showOnionSkinSettings) {
            OnionSkinSettingsSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showShapePicker) {
            ShapePickerSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showAllToolsPicker) {
            AllToolsPickerSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showLayerFXDialog) {
            LayerFXSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showTextPrompt) {
            TextPromptSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showAiVoicePrompt) {
            AiVoicePromptSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showLoopSequenceDialog) {
            LoopSequenceSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showRotoscopingPicker) {
            PhotoPickerView { pickedImage, _ in
                viewModel.setRotoscopingReference(image: pickedImage)
            }
        }
    }
}
