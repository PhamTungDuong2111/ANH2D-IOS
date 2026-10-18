import SwiftUI

public struct CanvasSettingsSheet: View {
    @ObservedObject public var viewModel: ProjectViewModel
    @Environment(\.presentationMode) var presentationMode

    public var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Tỷ lệ khung hình & Độ phân giải")) {
                    Picker("Preset Canvas", selection: Binding(
                        get: { viewModel.project.preset },
                        set: { newPreset in
                            viewModel.project.setPreset(newPreset)
                            viewModel.drawingView.resetViewport()
                        }
                    )) {
                        ForEach(CanvasPreset.allCases) { preset in
                            Text(preset.rawValue).tag(preset)
                        }
                    }

                    HStack {
                        Text("Kích thước thực tế:")
                        Spacer()
                        Text("\(viewModel.project.width) x \(viewModel.project.height) px")
                            .foregroundColor(.gray)
                    }
                }

                Section(header: Text("Tốc độ khung hình (FPS)")) {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("Tốc độ chuyển động:")
                            Spacer()
                            Text("\(viewModel.project.fps) FPS")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(Color.flipaOrange)
                        }

                        Slider(
                            value: Binding(
                                get: { Double(viewModel.project.fps) },
                                set: { viewModel.project.fps = Int($0) }
                            ),
                            in: 1...30,
                            step: 1
                        )
                        .accentColor(Color.flipaOrange)

                        Text("Gợi ý: 12 FPS là chuẩn hoạt hình FlipaClip truyền thống, 24 FPS cho chuyển động điện ảnh mượt mà.")
                            .font(.system(size: 11))
                            .foregroundColor(.gray)
                    }
                }

                Section(header: Text("Màu nền Canvas & Bút vẽ")) {
                    Toggle("Vẽ ngoài khung hình (Draw Outside Canvas)", isOn: Binding(
                        get: { viewModel.project.drawOutsideCanvas },
                        set: {
                            viewModel.project.drawOutsideCanvas = $0
                            viewModel.drawingView.setNeedsDisplay()
                        }
                    ))

                    Toggle("Chỉ nhận Apple Pencil (Palm Rejection)", isOn: Binding(
                        get: { viewModel.project.stylusOnlyMode },
                        set: {
                            viewModel.project.stylusOnlyMode = $0
                            viewModel.drawingView.stylusHelper.isStylusOnlyMode = $0
                        }
                    ))
                }

                Section(header: Text("Thông tin dự án")) {
                    TextField("Tên dự án hoạt hình", text: $viewModel.project.title)
                }
            }
            .navigationTitle("Cài Đặt Canvas")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Xong") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(Color.flipaOrange)
                    .font(.system(size: 15, weight: .bold))
                }
            }
        }
    }
}
