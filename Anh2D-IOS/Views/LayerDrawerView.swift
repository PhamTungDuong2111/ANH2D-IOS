import SwiftUI

public struct LayerDrawerView: View {
    @ObservedObject public var viewModel: ProjectViewModel

    public var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Quản Lý Lớp (Layers)")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(viewModel.project.isDarkMode ? .white : .black)
                    Text("\(viewModel.project.layers.count)/10 lớp • FlipaClip Plus")
                        .font(.system(size: 11))
                        .foregroundColor(Color.flipaOrange)
                }

                Spacer()

                Button(action: { viewModel.addLayer() }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Color.flipaOrange)
                }

                Button(action: {
                    withAnimation(.spring()) {
                        viewModel.showLayerDrawer = false
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(viewModel.project.isDarkMode ? Color.flipaPanelDark : Color(hex: "#F1F5F9"))

            Divider()

            // Active Layer Detailed Settings
            if let activeLayer = viewModel.project.activeLayer {
                VStack(spacing: 12) {
                    HStack {
                        Text("Cài đặt: \(activeLayer.name)")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(viewModel.project.isDarkMode ? .white : .black)
                        Spacer()
                    }

                    // Opacity Slider
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Độ mờ đục:")
                                .font(.system(size: 12))
                            Spacer()
                            Text("\(Int(activeLayer.opacity * 100))%")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Color.flipaOrange)
                        }
                        Slider(
                            value: Binding(
                                get: { activeLayer.opacity },
                                set: { newVal in
                                    if let idx = viewModel.project.layers.firstIndex(where: { $0.id == activeLayer.id }) {
                                        viewModel.project.layers[idx].opacity = newVal
                                        viewModel.drawingView.setNeedsDisplay()
                                    }
                                }
                            ),
                            in: 0.05...1.0,
                            step: 0.05
                        )
                        .accentColor(Color.flipaOrange)
                    }

                    // Blend Mode Picker
                    HStack {
                        Text("Hòa trộn:")
                            .font(.system(size: 12))
                        Spacer()
                        Picker("Blend", selection: Binding(
                            get: { activeLayer.blendMode },
                            set: { newMode in
                                if let idx = viewModel.project.layers.firstIndex(where: { $0.id == activeLayer.id }) {
                                    viewModel.project.layers[idx].blendMode = newMode
                                    viewModel.drawingView.setNeedsDisplay()
                                }
                            }
                        )) {
                            ForEach(BlendMode.allCases) { mode in
                                Text(mode.title).tag(mode)
                            }
                        }
                        .pickerStyle(.menu)
                    }

                    // Toggles: Clipping Mask & Alpha Lock
                    HStack(spacing: 12) {
                        Button(action: {
                            if let idx = viewModel.project.layers.firstIndex(where: { $0.id == activeLayer.id }) {
                                viewModel.project.layers[idx].isClippingMask.toggle()
                                viewModel.drawingView.setNeedsDisplay()
                            }
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "square.fill.and.line.vertical.and.square")
                                Text("Clipping")
                            }
                            .font(.system(size: 11, weight: .bold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(activeLayer.isClippingMask ? Color.flipaOrange : Color.gray.opacity(0.3))
                            .foregroundColor(activeLayer.isClippingMask ? .white : (viewModel.project.isDarkMode ? .white : .black))
                            .cornerRadius(6)
                        }

                        Button(action: {
                            if let idx = viewModel.project.layers.firstIndex(where: { $0.id == activeLayer.id }) {
                                viewModel.project.layers[idx].isAlphaLocked.toggle()
                                viewModel.drawingView.setNeedsDisplay()
                            }
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "checkerboard.rectangle")
                                Text("Alpha Lock")
                            }
                            .font(.system(size: 11, weight: .bold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(activeLayer.isAlphaLocked ? Color.flipaCyan : Color.gray.opacity(0.3))
                            .foregroundColor(activeLayer.isAlphaLocked ? .black : (viewModel.project.isDarkMode ? .white : .black))
                            .cornerRadius(6)
                        }

                        Button(action: { viewModel.showLayerFXDialog = true }) {
                            HStack(spacing: 4) {
                                Image(systemName: "sparkles")
                                Text("Hiệu ứng FX")
                            }
                            .font(.system(size: 11, weight: .bold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(Color.flipaYellow)
                            .foregroundColor(.black)
                            .cornerRadius(6)
                        }
                    }
                }
                .padding()
                .background(viewModel.project.isDarkMode ? Color.flipaPanelElevated : Color.white)
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top, 8)
            }

            // Layers List (Reversed so top layer is at the top)
            List {
                ForEach(Array(viewModel.project.layers.enumerated().reversed()), id: \.element.id) { index, layer in
                    let isSelected = (index == viewModel.project.activeLayerIndex)

                    HStack(spacing: 10) {
                        // Visibility toggle
                        Button(action: {
                            viewModel.project.layers[index].isVisible.toggle()
                            viewModel.drawingView.setNeedsDisplay()
                        }) {
                            Image(systemName: layer.isVisible ? "eye.fill" : "eye.slash.fill")
                                .foregroundColor(layer.isVisible ? Color.flipaOrange : .gray)
                        }

                        // Lock toggle
                        Button(action: {
                            viewModel.project.layers[index].isLocked.toggle()
                        }) {
                            Image(systemName: layer.isLocked ? "lock.fill" : "lock.open.fill")
                                .foregroundColor(layer.isLocked ? Color.flipaYellow : .gray.opacity(0.5))
                        }

                        // Layer Name
                        VStack(alignment: .leading, spacing: 2) {
                            Text(layer.name)
                                .font(.system(size: 13, weight: isSelected ? .bold : .medium))
                                .foregroundColor(viewModel.project.isDarkMode ? .white : .black)

                            if layer.blendMode != .normal || layer.isClippingMask || layer.isAlphaLocked {
                                Text("\(layer.blendMode.title) \(layer.isClippingMask ? "• Clip" : "") \(layer.isAlphaLocked ? "• Alpha" : "")")
                                    .font(.system(size: 10))
                                    .foregroundColor(.gray)
                            }
                        }

                        Spacer()

                        // Duplicate button
                        Button(action: { viewModel.duplicateLayer(at: index) }) {
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }

                        // Delete button
                        Button(action: { viewModel.deleteLayer(at: index) }) {
                            Image(systemName: "trash")
                                .font(.system(size: 12))
                                .foregroundColor(Color.flipaRed)
                        }
                    }
                    .padding(.vertical, 4)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewModel.project.activeLayerIndex = index
                        viewModel.drawingView.setNeedsDisplay()
                    }
                    .listRowBackground(isSelected ? Color.flipaOrange.opacity(0.2) : Color.clear)
                }
            }
            .listStyle(.plain)
        }
        .frame(width: 320)
        .background(viewModel.project.isDarkMode ? Color.flipaDarkBg : Color(hex: "#F8FAFC"))
        .shadow(color: Color.black.opacity(0.3), radius: 8, x: -4, y: 0)
    }
}
