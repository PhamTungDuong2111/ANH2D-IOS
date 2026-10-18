import SwiftUI

public struct ToolDockView: View {
    @ObservedObject public var viewModel: ProjectViewModel
    @State private var showBrushSizeSlider: Bool = false

    public var body: some View {
        VStack(spacing: 8) {
            // Pen
            toolButton(for: .pen)
            // Pencil
            toolButton(for: .pencil)
            // Brush
            toolButton(for: .brush)
            // Highlighter
            toolButton(for: .highlighter)
            // Eraser
            toolButton(for: .eraser)
            // Bucket
            toolButton(for: .bucket)
            // Shapes
            Button(action: {
                viewModel.currentTool = .shapes
                viewModel.showShapePicker = true
            }) {
                Image(systemName: viewModel.currentShape.iconName)
                    .font(.system(size: 16))
                    .frame(width: 38, height: 38)
                    .background(viewModel.currentTool == .shapes ? Color.flipaOrange : Color.clear)
                    .foregroundColor(viewModel.currentTool == .shapes ? .white : (viewModel.project.isDarkMode ? .white : .black))
                    .cornerRadius(8)
            }

            // Text
            Button(action: {
                viewModel.currentTool = .text
                viewModel.showTextPrompt = true
            }) {
                Image(systemName: ToolType.text.iconName)
                    .font(.system(size: 16))
                    .frame(width: 38, height: 38)
                    .background(viewModel.currentTool == .text ? Color.flipaOrange : Color.clear)
                    .foregroundColor(viewModel.currentTool == .text ? .white : (viewModel.project.isDarkMode ? .white : .black))
                    .cornerRadius(8)
            }

            // Lasso
            toolButton(for: .lasso)

            // Ruler
            Button(action: {
                switch viewModel.rulerType {
                case .none: viewModel.rulerType = .straight
                case .straight: viewModel.rulerType = .circle
                case .circle: viewModel.rulerType = .square
                case .square: viewModel.rulerType = .none
                }
                viewModel.drawingView.rulerOverlay.rulerType = viewModel.rulerType
                viewModel.drawingView.setNeedsDisplay()
            }) {
                Image(systemName: viewModel.rulerType.iconName)
                    .font(.system(size: 16))
                    .frame(width: 38, height: 38)
                    .background(viewModel.rulerType != .none ? Color.flipaOrange : Color.clear)
                    .foregroundColor(viewModel.rulerType != .none ? .white : (viewModel.project.isDarkMode ? .white : .black))
                    .cornerRadius(8)
            }

            Divider()
                .frame(width: 24)
                .background(Color.gray.opacity(0.4))

            // Color Swatch with native ColorPicker
            ColorPicker("", selection: $viewModel.brushColor)
                .labelsHidden()
                .frame(width: 32, height: 32)
                .background(viewModel.brushColor)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 2))

            // Brush Size Button
            Button(action: { showBrushSizeSlider.toggle() }) {
                ZStack {
                    Circle()
                        .fill(viewModel.project.isDarkMode ? Color.flipaPanelElevated : Color.white)
                        .frame(width: 32, height: 32)
                    Circle()
                        .fill(viewModel.brushColor)
                        .frame(width: min(24, max(4, viewModel.brushSize * 0.8)), height: min(24, max(4, viewModel.brushSize * 0.8)))
                }
            }
            .popover(isPresented: $showBrushSizeSlider) {
                VStack(spacing: 12) {
                    Text("Kích thước nét vẽ: \(Int(viewModel.brushSize)) px")
                        .font(.system(size: 13, weight: .bold))
                    Slider(value: $viewModel.brushSize, in: 1...60, step: 1)
                        .accentColor(Color.flipaOrange)
                        .frame(width: 180)

                    Text("Độ trong suốt: \(Int(viewModel.brushOpacity * 100))%")
                        .font(.system(size: 13, weight: .bold))
                    Slider(value: $viewModel.brushOpacity, in: 0.1...1.0, step: 0.05)
                        .accentColor(Color.flipaOrange)
                        .frame(width: 180)
                }
                .padding()
                .background(viewModel.project.isDarkMode ? Color.flipaPanelDark : Color.white)
            }

            // Rotoscoping Reference Button
            Button(action: { viewModel.showRotoscopingPicker = true }) {
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 15))
                    .frame(width: 38, height: 38)
                    .background(Color.flipaPanelElevated)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }

            // More tools menu (smudge, blur)
            Button(action: { viewModel.showAllToolsPicker = true }) {
                Image(systemName: "ellipsis.circle")
                    .font(.system(size: 16))
                    .frame(width: 38, height: 38)
                    .background(Color.clear)
                    .foregroundColor(viewModel.project.isDarkMode ? .white : .black)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .background(viewModel.project.isDarkMode ? Color.flipaPanelDark.opacity(0.95) : Color(hex: "#F8FAFC").opacity(0.95))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.2), radius: 6, x: 2, y: 2)
    }

    private func toolButton(for tool: ToolType) -> some View {
        Button(action: {
            viewModel.currentTool = tool
        }) {
            Image(systemName: tool.iconName)
                .font(.system(size: 16))
                .frame(width: 38, height: 38)
                .background(viewModel.currentTool == tool ? Color.flipaOrange : Color.clear)
                .foregroundColor(viewModel.currentTool == tool ? .white : (viewModel.project.isDarkMode ? .white : .black))
                .cornerRadius(8)
        }
    }
}
