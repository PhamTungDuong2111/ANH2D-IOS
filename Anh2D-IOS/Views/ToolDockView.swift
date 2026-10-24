import SwiftUI

public struct ToolDockView: View {
    @ObservedObject public var viewModel: ProjectViewModel
    @ObservedObject private var loc = LocalizationManager.shared

    let presetColors: [String] = [
        "#000000", "#FFFFFF", "#FF5353", "#FF9500",
        "#FFCC00", "#34C759", "#00C7BE", "#007AFF",
        "#5856D6", "#AF52DE", "#FF2D55", "#8E8E93"
    ]

    public var body: some View {
        HStack(alignment: .top, spacing: 10) {
            // Main Floating Tool Dock (matching ADR #tools-dock)
            VStack(spacing: 8) {
                // 1. Pen Tool (Bút vẽ)
                toolDockButton(tool: .pen, icon: "pencil.tip", titleKey: "tool_pen")

                // 2. Eraser Tool (Tẩy)
                toolDockButton(tool: .eraser, icon: "eraser.fill", titleKey: "tool_eraser")

                // 3. Paint Bucket (Thùng sơn / Tô màu)
                toolDockButton(tool: .bucket, icon: "drop.fill", titleKey: "tool_bucket")

                // 4. Shapes & Ruler Tool (Hình học)
                toolDockButton(tool: .shapes, icon: viewModel.currentShape.iconName, titleKey: "tool_shapes")

                // 5. Text Tool (Chèn văn bản)
                toolDockButton(tool: .text, icon: "textformat", titleKey: "tool_text")

                // Divider
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 28, height: 1)
                    .padding(.vertical, 2)

                // 6. Color Swatch Disc (Bảng màu)
                Button(action: {
                    withAnimation(.spring()) {
                        viewModel.toggleColorPicker()
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(viewModel.brushColor)
                            .frame(width: 32, height: 32)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 2.5)
                            )
                            .shadow(color: Color.black.opacity(0.3), radius: 3)
                    }
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 6)
            .background(viewModel.project.isDarkMode ? Color.flipaSurface.opacity(0.95) : Color(hex: "#F8FAFC").opacity(0.95))
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(viewModel.project.isDarkMode ? Color.flipaBorder : Color.black.opacity(0.08), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.25), radius: 8, x: 2, y: 3)

            // TOOL OPTIONS POPOUT (matching ADR #tool-options-popout)
            if viewModel.showToolOptionsPopout {
                toolOptionsCard
                    .transition(.move(edge: .leading).combined(with: .opacity))
            }

            // COLOR PICKER POPOUT (matching ADR #color-picker-popout)
            if viewModel.showColorPickerPopout {
                colorPickerCard
                    .transition(.move(edge: .leading).combined(with: .opacity))
            }
        }
    }

    private func toolDockButton(tool: ToolType, icon: String, titleKey: String) -> some View {
        let isActive = (viewModel.currentTool == tool)
        return Button(action: {
            withAnimation(.spring()) {
                viewModel.selectTool(tool)
            }
        }) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .frame(width: 38, height: 38)
                .background(isActive ? Color.flipaCoral : Color.clear)
                .foregroundColor(isActive ? .white : (viewModel.project.isDarkMode ? .white : .black))
                .cornerRadius(10)
                .shadow(color: isActive ? Color.flipaCoral.opacity(0.4) : Color.clear, radius: 4)
        }
    }

    // MARK: - Tool Options Popout Card
    private var toolOptionsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text(popoutTitle)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(viewModel.project.isDarkMode ? .white : .black)

                Spacer()

                Button(action: {
                    withAnimation(.spring()) {
                        viewModel.showToolOptionsPopout = false
                    }
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.gray)
                        .frame(width: 24, height: 24)
                        .background(Color.gray.opacity(0.15))
                        .clipShape(Circle())
                }
            }

            // Brush Types (if pen/pencil/brush/highlighter)
            if viewModel.currentTool == .pen || viewModel.currentTool == .pencil || viewModel.currentTool == .brush || viewModel.currentTool == .highlighter {
                VStack(alignment: .leading, spacing: 6) {
                    Text(loc.t("brush_type"))
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.gray)

                    HStack(spacing: 6) {
                        brushTypeButton(tool: .pen, label: loc.t("tool_pen"))
                        brushTypeButton(tool: .pencil, label: loc.t("tool_pencil"))
                        brushTypeButton(tool: .brush, label: loc.t("tool_marker"))
                        brushTypeButton(tool: .highlighter, label: loc.t("tool_highlighter"))
                    }
                }
            }

            // Shapes selector (if shapes active)
            if viewModel.currentTool == .shapes {
                VStack(alignment: .leading, spacing: 6) {
                    Text(loc.t("tool_shapes"))
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.gray)

                    HStack(spacing: 6) {
                        shapeTypeButton(shape: .line, label: loc.t("shape_line"))
                        shapeTypeButton(shape: .rectangle, label: loc.t("shape_rect"))
                        shapeTypeButton(shape: .circle, label: loc.t("shape_circle"))
                    }
                }
            }

            // Size Slider
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(loc.t("size"))
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.gray)
                    Spacer()
                    Text("\(Int(viewModel.brushSize))px")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.flipaCoral)
                }

                Slider(value: $viewModel.brushSize, in: 1...80, step: 1)
                    .accentColor(Color.flipaCoral)
            }

            // Opacity Slider (if not eraser)
            if viewModel.currentTool != .eraser {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(loc.t("opacity"))
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.gray)
                        Spacer()
                        Text("\(Int(viewModel.brushOpacity * 100))%")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(Color.flipaCoral)
                    }

                    Slider(value: $viewModel.brushOpacity, in: 0.05...1.0, step: 0.05)
                        .accentColor(Color.flipaCoral)
                }
            }

            // Clear Canvas Button
            Button(action: {
                viewModel.clearCurrentCanvas()
            }) {
                HStack {
                    Image(systemName: "trash")
                    Text(loc.t("clear_canvas"))
                }
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(Color.flipaRed)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 7)
                .background(Color.flipaRed.opacity(0.12))
                .cornerRadius(8)
            }
        }
        .padding(12)
        .frame(width: 230)
        .background(viewModel.project.isDarkMode ? Color.flipaSurface : Color.white)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(viewModel.project.isDarkMode ? Color.flipaBorder : Color.black.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 2, y: 4)
    }

    private var popoutTitle: String {
        switch viewModel.currentTool {
        case .eraser: return loc.t("tool_eraser")
        case .shapes: return loc.t("tool_shapes")
        default: return loc.t("tool_pen")
        }
    }

    private func brushTypeButton(tool: ToolType, label: String) -> some View {
        let isSelected = (viewModel.currentTool == tool)
        return Button(action: {
            viewModel.currentTool = tool
        }) {
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .padding(.horizontal, 6)
                .padding(.vertical, 5)
                .background(isSelected ? Color.flipaCoral : (viewModel.project.isDarkMode ? Color.flipaPanelElevated : Color(hex: "#F1F5F9")))
                .foregroundColor(isSelected ? .white : (viewModel.project.isDarkMode ? .white : .black))
                .cornerRadius(6)
        }
    }

    private func shapeTypeButton(shape: ShapeType, label: String) -> some View {
        let isSelected = (viewModel.currentShape == shape)
        return Button(action: {
            viewModel.currentShape = shape
        }) {
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(isSelected ? Color.flipaCoral : (viewModel.project.isDarkMode ? Color.flipaPanelElevated : Color(hex: "#F1F5F9")))
                .foregroundColor(isSelected ? .white : (viewModel.project.isDarkMode ? .white : .black))
                .cornerRadius(6)
        }
    }

    // MARK: - Color Picker Popout Card
    private var colorPickerCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text(loc.t("color_palette"))
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(viewModel.project.isDarkMode ? .white : .black)

                Spacer()

                Button(action: {
                    withAnimation(.spring()) {
                        viewModel.showColorPickerPopout = false
                    }
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.gray)
                        .frame(width: 24, height: 24)
                        .background(Color.gray.opacity(0.15))
                        .clipShape(Circle())
                }
            }

            // 12 Preset Color Swatches Grid (matching ADR .color-swatches-grid)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
                ForEach(presetColors, id: \.self) { hex in
                    let col = Color(hex: hex)
                    Button(action: {
                        viewModel.brushColor = col
                    }) {
                        Circle()
                            .fill(col)
                            .frame(width: 32, height: 32)
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.8), lineWidth: viewModel.brushColor == col ? 3 : 1)
                            )
                            .shadow(color: Color.black.opacity(0.15), radius: 2)
                    }
                }
            }

            // Hex Input and Native Color Picker
            HStack(spacing: 8) {
                Text(UIColor(viewModel.brushColor).toHex())
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(viewModel.project.isDarkMode ? Color.flipaPanelElevated : Color(hex: "#F1F5F9"))
                    .cornerRadius(8)
                    .foregroundColor(viewModel.project.isDarkMode ? .white : .black)

                Spacer()

                ColorPicker("", selection: $viewModel.brushColor)
                    .labelsHidden()
                    .frame(width: 32, height: 32)
            }
        }
        .padding(12)
        .frame(width: 210)
        .background(viewModel.project.isDarkMode ? Color.flipaSurface : Color.white)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(viewModel.project.isDarkMode ? Color.flipaBorder : Color.black.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 2, y: 4)
    }
}
