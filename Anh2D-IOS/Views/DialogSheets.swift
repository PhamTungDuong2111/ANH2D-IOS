import SwiftUI
import PhotosUI

// MARK: - Onion Skin Settings Sheet
public struct OnionSkinSettingsSheet: View {
    @ObservedObject public var viewModel: ProjectViewModel
    @Environment(\.presentationMode) var presentationMode

    public var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Khung hình trước (Màu đỏ/cam)")) {
                    Stepper("Số frame trước: \(viewModel.onionSkinFramesBefore)", value: $viewModel.onionSkinFramesBefore, in: 1...5)
                }

                Section(header: Text("Khung hình sau (Màu xanh lá)")) {
                    Stepper("Số frame sau: \(viewModel.onionSkinFramesAfter)", value: $viewModel.onionSkinFramesAfter, in: 1...5)
                }

                Section(header: Text("Độ mờ đục hành tây (Opacity)")) {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("Độ mờ:")
                            Spacer()
                            Text("\(Int(viewModel.onionSkinAlpha * 100))%")
                                .fontWeight(.bold)
                                .foregroundColor(Color.flipaOrange)
                        }
                        Slider(value: $viewModel.onionSkinAlpha, in: 0.1...0.8, step: 0.05)
                            .accentColor(Color.flipaOrange)
                    }
                }
            }
            .navigationTitle("Tùy Chỉnh Onion Skin")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Xong") {
                        viewModel.drawingView.onionSkinFramesBefore = viewModel.onionSkinFramesBefore
                        viewModel.drawingView.onionSkinFramesAfter = viewModel.onionSkinFramesAfter
                        viewModel.drawingView.onionSkinAlpha = viewModel.onionSkinAlpha
                        viewModel.drawingView.setNeedsDisplay()
                        presentationMode.wrappedValue.dismiss()
                    }
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color.flipaOrange)
                }
            }
        }
    }
}

// MARK: - Shape Picker Sheet
public struct ShapePickerSheet: View {
    @ObservedObject public var viewModel: ProjectViewModel
    @Environment(\.presentationMode) var presentationMode

    public var body: some View {
        NavigationView {
            List(ShapeType.allCases) { shape in
                Button(action: {
                    viewModel.currentShape = shape
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: shape.iconName)
                            .font(.system(size: 20))
                            .foregroundColor(Color.flipaOrange)
                            .frame(width: 32)

                        Text(shape.displayName)
                            .foregroundColor(viewModel.project.isDarkMode ? .white : .black)

                        Spacer()

                        if viewModel.currentShape == shape {
                            Image(systemName: "checkmark")
                                .foregroundColor(Color.flipaOrange)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Chọn Hình Học")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - All Tools Picker Sheet
public struct AllToolsPickerSheet: View {
    @ObservedObject public var viewModel: ProjectViewModel
    @Environment(\.presentationMode) var presentationMode

    public var body: some View {
        NavigationView {
            List(ToolType.allCases) { tool in
                Button(action: {
                    viewModel.currentTool = tool
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: tool.iconName)
                            .font(.system(size: 20))
                            .foregroundColor(Color.flipaOrange)
                            .frame(width: 32)

                        Text(tool.displayName)
                            .foregroundColor(viewModel.project.isDarkMode ? .white : .black)

                        Spacer()

                        if viewModel.currentTool == tool {
                            Image(systemName: "checkmark")
                                .foregroundColor(Color.flipaOrange)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Tất Cả Công Cụ Vẽ")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Layer Visual FX Sheet
public struct LayerFXSheet: View {
    @ObservedObject public var viewModel: ProjectViewModel
    @Environment(\.presentationMode) var presentationMode

    public var body: some View {
        NavigationView {
            Form {
                if let layer = viewModel.project.activeLayer {
                    Section(header: Text("Hiệu ứng phát sáng (Glow FX)")) {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("Bán kính phát sáng:")
                                Spacer()
                                Text("\(Int(layer.glowRadius)) px")
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.flipaOrange)
                            }
                            Slider(
                                value: Binding(
                                    get: { Double(layer.glowRadius) },
                                    set: { val in
                                        if let idx = viewModel.project.layers.firstIndex(where: { $0.id == layer.id }) {
                                            viewModel.project.layers[idx].glowRadius = CGFloat(val)
                                            viewModel.drawingView.setNeedsDisplay()
                                        }
                                    }
                                ),
                                in: 0...30,
                                step: 1
                            )
                            .accentColor(Color.flipaOrange)
                        }
                    }

                    Section(header: Text("Hiệu ứng làm mờ (Blur FX)")) {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("Độ mờ ống kính:")
                                Spacer()
                                Text("\(Int(layer.blurRadius)) px")
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.flipaCyan)
                            }
                            Slider(
                                value: Binding(
                                    get: { Double(layer.blurRadius) },
                                    set: { val in
                                        if let idx = viewModel.project.layers.firstIndex(where: { $0.id == layer.id }) {
                                            viewModel.project.layers[idx].blurRadius = CGFloat(val)
                                            viewModel.drawingView.setNeedsDisplay()
                                        }
                                    }
                                ),
                                in: 0...20,
                                step: 1
                            )
                            .accentColor(Color.flipaCyan)
                        }
                    }

                    Section(header: Text("Hiệu ứng Mosaic Retro 8-bit (Pixel Effect)")) {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("Kích thước Pixel:")
                                Spacer()
                                Text(layer.pixelEffectSize == 1 ? "Tắt" : "\(layer.pixelEffectSize)x")
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.flipaNeonGreen)
                            }
                            Picker("Pixel Size", selection: Binding(
                                get: { layer.pixelEffectSize },
                                set: { size in
                                    if let idx = viewModel.project.layers.firstIndex(where: { $0.id == layer.id }) {
                                        viewModel.project.layers[idx].pixelEffectSize = size
                                        viewModel.drawingView.setNeedsDisplay()
                                    }
                                }
                            )) {
                                Text("1x (Bình thường)").tag(1)
                                Text("4x (Pixel vừa)").tag(4)
                                Text("8x (Pixel retro)").tag(8)
                                Text("16x (8-bit siêu to)").tag(16)
                            }
                            .pickerStyle(.segmented)
                        }
                    }

                    Section {
                        Button("Xóa Hết Hiệu Ứng Layer") {
                            if let idx = viewModel.project.layers.firstIndex(where: { $0.id == layer.id }) {
                                viewModel.project.layers[idx].glowRadius = 0
                                viewModel.project.layers[idx].blurRadius = 0
                                viewModel.project.layers[idx].pixelEffectSize = 1
                                viewModel.drawingView.setNeedsDisplay()
                            }
                            presentationMode.wrappedValue.dismiss()
                        }
                        .foregroundColor(Color.flipaRed)
                    }
                }
            }
            .navigationTitle("Hiệu Ứng Lớp (Visual FX)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Xong") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Text Prompt Sheet
public struct TextPromptSheet: View {
    @ObservedObject public var viewModel: ProjectViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var inputText: String = ""

    public var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Nội dung văn bản chèn vào layer")) {
                    TextField("Nhập chữ cần đóng dấu lên khung hình...", text: $inputText)
                }

                Section {
                    Button("Đóng Dấu Văn Bản Lên Canvas") {
                        if !inputText.trimmingCharacters(in: .whitespaces).isEmpty {
                            let center = CGPoint(x: viewModel.project.width / 4, y: viewModel.project.height / 2)
                            viewModel.drawingView.stampText(inputText, at: center)
                            viewModel.showToast("Đã chèn văn bản lên layer!")
                        }
                        presentationMode.wrappedValue.dismiss()
                    }
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color.flipaOrange)
                }
            }
            .navigationTitle("Chèn Văn Bản")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Hủy") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - AI Voice Prompt Sheet
public struct AiVoicePromptSheet: View {
    @ObservedObject public var viewModel: ProjectViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var script: String = ""

    public var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Kịch bản lời thoại AI (AI Voice Maker)")) {
                    TextEditor(text: $script)
                        .frame(height: 100)
                }

                Section {
                    Button("Tạo Giọng Nói AI Ngay") {
                        if let track = viewModel.activeAiVoiceTrack {
                            viewModel.generateAiVoice(script: script, for: track)
                        }
                        presentationMode.wrappedValue.dismiss()
                    }
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color.flipaCyan)
                }
            }
            .navigationTitle("FlipaClip AI Voice Maker")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Hủy") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Loop Sequence Sheet
public struct LoopSequenceSheet: View {
    @ObservedObject public var viewModel: ProjectViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var times: Int = 2

    public var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Lặp lại chuỗi khung hình")) {
                    Stepper("Số lần lặp: \(times) lần", value: $times, in: 2...10)
                    Text("Nhân bản toàn bộ sequence hiện tại (\(viewModel.project.frames.count) frames) lặp lại liên tiếp để tạo chuyển động tuần hoàn.")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }

                Section {
                    Button("Áp Dụng Lặp Chuỗi") {
                        viewModel.timelineManager.loopSequence(times: times)
                        viewModel.showToast("Đã lặp chuỗi khung hình \(times) lần!")
                        presentationMode.wrappedValue.dismiss()
                    }
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color.flipaOrange)
                }
            }
            .navigationTitle("Lặp Chuỗi Khung Hình")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Hủy") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Photo Picker with Rotoscoping & Magic Cut AI
public struct PhotoPickerView: UIViewControllerRepresentable {
    public let onImagePicked: (UIImage, Bool) -> Void // (image, isMagicCut)

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }

    public func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    public class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: PhotoPickerView

        init(_ parent: PhotoPickerView) {
            self.parent = parent
        }

        public func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
        ) {
            picker.dismiss(animated: true)
            if let image = info[.originalImage] as? UIImage {
                self.parent.onImagePicked(image, false)
            }
        }

        public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}
