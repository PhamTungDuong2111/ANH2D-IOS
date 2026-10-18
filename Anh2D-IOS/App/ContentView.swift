import SwiftUI

public struct ContentView: View {
    @StateObject private var viewModel = ProjectViewModel()

    public var body: some View {
        ZStack {
            // Workspace Background
            (viewModel.project.isDarkMode ? Color.flipaDarkBg : Color(hex: "#E2E8F0"))
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top Navigation Bar
                TopNavigationBar(viewModel: viewModel)

                // Central Workspace Area
                ZStack(alignment: .leading) {
                    // Native Canvas
                    CanvasViewRepresentable(
                        project: viewModel.project,
                        currentTool: $viewModel.currentTool,
                        currentShape: $viewModel.currentShape,
                        brushColor: $viewModel.brushColor,
                        brushSize: $viewModel.brushSize,
                        brushOpacity: $viewModel.brushOpacity,
                        isOnionSkinEnabled: $viewModel.isOnionSkinEnabled,
                        rulerType: $viewModel.rulerType,
                        drawingView: viewModel.drawingView
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                    // Floating Tool Dock on the left
                    ToolDockView(viewModel: viewModel)
                        .padding(.leading, 12)
                }

                // Studio Mode Audio Section
                if viewModel.currentLayout == .studio {
                    AudioStudioView(viewModel: viewModel)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                // Bottom Animation Timeline
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
        .sheet(isPresented: $viewModel.showCanvasSettings) {
            CanvasSettingsSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showChallengesDialog) {
            ChallengesDialog(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showExportSheet) {
            ExportSheet(viewModel: viewModel)
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
