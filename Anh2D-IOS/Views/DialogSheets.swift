import SwiftUI
import PhotosUI

// MARK: - Projects Gallery Sheet (matching ADR #projects-gallery-modal)
public struct ProjectsGallerySheet: View {
    @ObservedObject public var viewModel: ProjectViewModel
    @ObservedObject private var loc = LocalizationManager.shared
    @Environment(\.presentationMode) var presentationMode

    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // New Project & Samples Bar
                    HStack(spacing: 8) {
                        Button(action: {
                            viewModel.showNewProjectSheet = true
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 15, weight: .bold))
                                Text(loc.t("new_project"))
                                    .font(.system(size: 13, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(Color.flipaCoral)
                            .cornerRadius(10)
                            .shadow(color: Color.flipaCoral.opacity(0.3), radius: 4)
                        }

                        Spacer()

                        // Sample Projects Quick Loaders
                        Button(action: {
                            viewModel.loadSampleBall()
                        }) {
                            Text("⚾️ " + loc.t("sample_bouncing_ball"))
                                .font(.system(size: 11, weight: .bold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 8)
                                .background(viewModel.project.isDarkMode ? Color.flipaPanelElevated : Color(hex: "#F1F5F9"))
                                .foregroundColor(viewModel.project.isDarkMode ? .white : .black)
                                .cornerRadius(8)
                        }

                        Button(action: {
                            viewModel.loadSampleStickman()
                        }) {
                            Text("🏃 " + loc.t("sample_stickman"))
                                .font(.system(size: 11, weight: .bold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 8)
                                .background(viewModel.project.isDarkMode ? Color.flipaPanelElevated : Color(hex: "#F1F5F9"))
                                .foregroundColor(viewModel.project.isDarkMode ? .white : .black)
                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)

                    // Projects List Grid
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.projectsList) { proj in
                            projectCard(for: proj)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 20)
            }
            .navigationTitle(loc.t("my_projects"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(loc.t("done")) {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(Color.flipaCoral)
                    .font(.system(size: 15, weight: .bold))
                }
            }
        }
    }

    private func projectCard(for proj: Project) -> some View {
        let isCurrent = (proj.id == viewModel.project.id)
        return HStack(spacing: 12) {
            // First frame thumbnail
            ZStack {
                if let firstFrame = proj.frames.first {
                    Image(uiImage: FrameThumbnailRenderer.renderThumbnail(for: firstFrame, project: proj))
                        .resizable()
                        .aspectRatio(16/9, contentMode: .fit)
                        .frame(width: 90, height: 56)
                        .background(Color.white)
                        .cornerRadius(8)
                } else {
                    Color.white
                        .frame(width: 90, height: 56)
                        .cornerRadius(8)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isCurrent ? Color.flipaCoral : Color.gray.opacity(0.3), lineWidth: isCurrent ? 2.5 : 1)
            )

            // Info
            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(proj.title)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(viewModel.project.isDarkMode ? .white : .black)
                        .lineLimit(1)

                    if isCurrent {
                        Text("Đang mở")
                            .font(.system(size: 9, weight: .black))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.flipaCoral)
                            .foregroundColor(.white)
                            .cornerRadius(4)
                    }
                }

                Text("\(proj.width)x\(proj.height) • \(proj.fps) FPS")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.gray)

                Text(String(format: loc.t("frames_count"), proj.frames.count))
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(Color.flipaCoral)
            }

            Spacer()

            // Actions
            HStack(spacing: 6) {
                if !isCurrent {
                    Button(action: {
                        viewModel.switchProject(to: proj)
                    }) {
                        Text(loc.t("open_project"))
                            .font(.system(size: 11, weight: .bold))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.flipaCoral)
                            .foregroundColor(.white)
                            .cornerRadius(6)
                    }
                }

                Button(action: {
                    viewModel.duplicateProject(target: proj)
                }) {
                    Image(systemName: "doc.on.doc")
                        .font(.system(size: 12))
                        .frame(width: 30, height: 30)
                        .background(viewModel.project.isDarkMode ? Color.flipaPanelElevated : Color(hex: "#F1F5F9"))
                        .foregroundColor(viewModel.project.isDarkMode ? .white : .black)
                        .cornerRadius(6)
                }

                Button(action: {
                    viewModel.deleteProject(target: proj)
                }) {
                    Image(systemName: "trash")
                        .font(.system(size: 12))
                        .frame(width: 30, height: 30)
                        .background(viewModel.project.isDarkMode ? Color.flipaPanelElevated : Color(hex: "#F1F5F9"))
                        .foregroundColor(Color.flipaRed)
                        .cornerRadius(6)
                }
            }
        }
        .padding(10)
        .background(viewModel.project.isDarkMode ? Color.flipaSurface : Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isCurrent ? Color.flipaCoral.opacity(0.5) : (viewModel.project.isDarkMode ? Color.flipaBorder : Color.black.opacity(0.06)), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.06), radius: 4, y: 2)
    }
}

// MARK: - New Project Sheet (matching ADR #new-project-modal)
public struct NewProjectSheet: View {
    @ObservedObject public var viewModel: ProjectViewModel
    @ObservedObject private var loc = LocalizationManager.shared
    @Environment(\.presentationMode) var presentationMode

    @State private var projTitle: String = "Hoạt hình mới"
    @State private var selectedPreset: CanvasPreset = .youtube16_9
    @State private var fps: Int = 12
    @State private var bgHex: String = "#FFFFFF"

    public var body: some View {
        NavigationView {
            Form {
                Section(header: Text(loc.t("project_title"))) {
                    TextField(loc.t("project_title_placeholder"), text: $projTitle)
                }

                Section(header: Text(loc.t("choose_canvas"))) {
                    Picker("Preset", selection: $selectedPreset) {
                        Text(loc.t("canvas_yt")).tag(CanvasPreset.youtube16_9)
                        Text(loc.t("canvas_tiktok")).tag(CanvasPreset.tiktok9_16)
                        Text(loc.t("canvas_insta")).tag(CanvasPreset.instagram1_1)
                        Text(loc.t("canvas_standard")).tag(CanvasPreset.standard4_3)
                    }
                    .pickerStyle(.inline)
                }

                Section(header: Text(loc.t("fps"))) {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(String(format: loc.t("current_fps"), fps))
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(Color.flipaCoral)
                            Spacer()
                        }
                        Slider(value: Binding(
                            get: { Double(fps) },
                            set: { fps = Int($0) }
                        ), in: 1...24, step: 1)
                        .accentColor(Color.flipaCoral)

                        Text(loc.t("fps_hint"))
                            .font(.system(size: 11))
                            .foregroundColor(.gray)
                    }
                }

                Section(header: Text(loc.t("choose_bg"))) {
                    Picker("Nền", selection: $bgHex) {
                        Text(loc.t("bg_white")).tag("#FFFFFF")
                        Text(loc.t("bg_paper")).tag("#FFFDF7")
                        Text(loc.t("bg_dark")).tag("#1E293B")
                        Text(loc.t("bg_chalkboard")).tag("#1B4D3E")
                    }
                    .pickerStyle(.menu)
                }

                Section {
                    Button(action: {
                        let finalTitle = projTitle.trimmingCharacters(in: .whitespaces).isEmpty ? "Dự án mới" : projTitle
                        viewModel.createNewProject(title: finalTitle, preset: selectedPreset, fps: fps, bgHex: bgHex)
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Spacer()
                            Text(loc.t("create_project"))
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.vertical, 8)
                        .background(Color.flipaCoral)
                        .cornerRadius(10)
                    }
                }
            }
            .navigationTitle(loc.t("new_project"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(loc.t("cancel")) {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Audio & Voiceover Modal (matching ADR #audio-modal)
public struct AudioModalSheet: View {
    @ObservedObject public var viewModel: ProjectViewModel
    @ObservedObject private var loc = LocalizationManager.shared
    @Environment(\.presentationMode) var presentationMode
    @State private var showAiMaker: Bool = false
    @State private var aiScript: String = ""

    public var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Spacer()

                // Big Round Microphone Button (72x72)
                Button(action: {
                    if let firstTrack = viewModel.project.audioTracks.first {
                        viewModel.toggleVoiceRecording(for: firstTrack)
                    } else {
                        viewModel.addAudioTrack()
                        if let first = viewModel.project.audioTracks.first {
                            viewModel.toggleVoiceRecording(for: first)
                        }
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(
                                colors: [Color.flipaCoral, Color(hex: "#FF3B30")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 80, height: 80)
                            .shadow(color: Color.flipaCoral.opacity(0.45), radius: viewModel.isRecordingMicLive ? 16 : 8)
                            .scaleEffect(viewModel.isRecordingMicLive ? 1.1 : 1.0)
                            .animation(viewModel.isRecordingMicLive ? Animation.easeInOut(duration: 0.6).repeatForever(autoreverses: true) : .default, value: viewModel.isRecordingMicLive)

                        Image(systemName: viewModel.isRecordingMicLive ? "stop.fill" : "mic.fill")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                    }
                }

                // Mic Status Label
                Text(viewModel.isRecordingMicLive ? loc.t("recording_live") : loc.t("record_voice"))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(viewModel.project.isDarkMode ? .white : .black)

                // Divider OR
                HStack(spacing: 12) {
                    Rectangle().frame(height: 1).foregroundColor(Color.gray.opacity(0.3))
                    Text("HOẶC").font(.system(size: 11, weight: .bold)).foregroundColor(.gray)
                    Rectangle().frame(height: 1).foregroundColor(Color.gray.opacity(0.3))
                }
                .padding(.horizontal, 30)

                // Audio File Picker Button
                Button(action: {
                    viewModel.showToast("Chức năng tải file đang khả dụng qua Files app")
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "square.and.arrow.down.fill")
                        Text(loc.t("upload_audio"))
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(viewModel.project.isDarkMode ? Color.flipaPanelElevated : Color(hex: "#F1F5F9"))
                    .foregroundColor(viewModel.project.isDarkMode ? .white : .black)
                    .cornerRadius(10)
                }

                // AI Voice Maker toggle button
                Button(action: {
                    showAiMaker.toggle()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .foregroundColor(Color.flipaCyan)
                        Text("Tạo giọng đọc AI Text-to-Speech")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .foregroundColor(Color.flipaCyan)
                }

                if showAiMaker {
                    VStack(spacing: 8) {
                        TextField("Nhập lời thoại cần AI lồng tiếng...", text: $aiScript)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal, 20)

                        Button(action: {
                            if let first = viewModel.project.audioTracks.first {
                                viewModel.generateAiVoice(script: aiScript, for: first)
                            }
                        }) {
                            Text("Tạo giọng nói AI")
                                .font(.system(size: 12, weight: .bold))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 6)
                                .background(Color.flipaCyan)
                                .foregroundColor(.black)
                                .cornerRadius(6)
                        }
                    }
                }

                // Delete Audio button
                Button(action: {
                    viewModel.removeAudioFromProject()
                }) {
                    Text(loc.t("delete_audio"))
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color.flipaRed)
                }

                Spacer()
            }
            .padding()
            .navigationTitle(loc.t("audio_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(loc.t("done")) {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(Color.flipaCoral)
                    .font(.system(size: 15, weight: .bold))
                }
            }
        }
    }
}

// MARK: - Settings & Animation Guide Modal (matching ADR #settings-modal)
public struct SettingsModalSheet: View {
    @ObservedObject public var viewModel: ProjectViewModel
    @ObservedObject private var loc = LocalizationManager.shared
    @Environment(\.presentationMode) var presentationMode

    public var body: some View {
        NavigationView {
            Form {
                // Language Selector
                Section(header: Text(loc.t("language"))) {
                    HStack(spacing: 10) {
                        Button(action: {
                            loc.currentLanguage = .vi
                        }) {
                            HStack {
                                Text("🇻🇳 Tiếng Việt")
                                    .font(.system(size: 13, weight: .bold))
                                Spacer()
                                if loc.currentLanguage == .vi {
                                    Image(systemName: "checkmark").foregroundColor(Color.flipaCoral)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .foregroundColor(loc.currentLanguage == .vi ? Color.flipaCoral : (viewModel.project.isDarkMode ? .white : .black))

                        Divider()

                        Button(action: {
                            loc.currentLanguage = .en
                        }) {
                            HStack {
                                Text("🇬🇧 English")
                                    .font(.system(size: 13, weight: .bold))
                                Spacer()
                                if loc.currentLanguage == .en {
                                    Image(systemName: "checkmark").foregroundColor(Color.flipaCoral)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .foregroundColor(loc.currentLanguage == .en ? Color.flipaCoral : (viewModel.project.isDarkMode ? .white : .black))
                    }
                }

                // Grid Overlay Toggle
                Section(header: Text("Lưới Căn Chỉnh")) {
                    Toggle(loc.t("grid_toggle"), isOn: Binding(
                        get: { viewModel.isGridVisible },
                        set: {
                            viewModel.isGridVisible = $0
                            viewModel.drawingView.isGridVisible = $0
                            viewModel.drawingView.setNeedsDisplay()
                        }
                    ))
                }

                // Onion Skin Settings
                Section(header: Text(loc.t("onion_settings"))) {
                    Stepper("Số khung trước (Đỏ): \(viewModel.onionSkinFramesBefore)", value: $viewModel.onionSkinFramesBefore, in: 1...5)
                    Stepper("Số khung sau (Xanh): \(viewModel.onionSkinFramesAfter)", value: $viewModel.onionSkinFramesAfter, in: 1...5)

                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Độ mờ đục:")
                            Spacer()
                            Text("\(Int(viewModel.onionSkinAlpha * 100))%")
                                .foregroundColor(Color.flipaCoral)
                        }
                        Slider(value: $viewModel.onionSkinAlpha, in: 0.1...0.8, step: 0.05)
                            .accentColor(Color.flipaCoral)
                    }
                }

                // Animation Tutorial / Guide (matching ADR Guide 5 steps)
                Section(header: Text(loc.t("help_guide"))) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(loc.t("guide_intro"))
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color.flipaCoral)
                        Text(loc.t("guide_step1")).font(.system(size: 11))
                        Text(loc.t("guide_step2")).font(.system(size: 11))
                        Text(loc.t("guide_step3")).font(.system(size: 11))
                        Text(loc.t("guide_step4")).font(.system(size: 11))
                        Text(loc.t("guide_step5")).font(.system(size: 11))
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle(loc.t("settings_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(loc.t("done")) {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(Color.flipaCoral)
                    .font(.system(size: 15, weight: .bold))
                }
            }
        }
    }
}

// MARK: - FPS Modal (matching ADR #fps-modal)
public struct FpsModalSheet: View {
    @ObservedObject public var viewModel: ProjectViewModel
    @ObservedObject private var loc = LocalizationManager.shared
    @Environment(\.presentationMode) var presentationMode

    public var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    Text("\(viewModel.project.fps) FPS")
                        .font(.system(size: 40, weight: .black, design: .monospaced))
                        .foregroundColor(Color.flipaCoral)

                    Text(loc.t("fps_hint"))
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 20)

                Slider(value: Binding(
                    get: { Double(viewModel.project.fps) },
                    set: { viewModel.project.fps = Int($0) }
                ), in: 1...30, step: 1)
                .accentColor(Color.flipaCoral)
                .padding(.horizontal, 24)

                Spacer()

                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text(loc.t("done"))
                        .font(.system(size: 14, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.flipaCoral)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
            }
            .navigationTitle(loc.t("fps"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(loc.t("cancel")) {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

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
                                .foregroundColor(Color.flipaCoral)
                        }
                        Slider(value: $viewModel.onionSkinAlpha, in: 0.1...0.8, step: 0.05)
                            .accentColor(Color.flipaCoral)
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
                    .foregroundColor(Color.flipaCoral)
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
                            .foregroundColor(Color.flipaCoral)
                            .frame(width: 32)

                        Text(shape.displayName)
                            .foregroundColor(viewModel.project.isDarkMode ? .white : .black)

                        Spacer()

                        if viewModel.currentShape == shape {
                            Image(systemName: "checkmark")
                                .foregroundColor(Color.flipaCoral)
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
                            .foregroundColor(Color.flipaCoral)
                            .frame(width: 32)

                        Text(tool.displayName)
                            .foregroundColor(viewModel.project.isDarkMode ? .white : .black)

                        Spacer()

                        if viewModel.currentTool == tool {
                            Image(systemName: "checkmark")
                                .foregroundColor(Color.flipaCoral)
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
                                    .foregroundColor(Color.flipaCoral)
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
                            .accentColor(Color.flipaCoral)
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
                                    .foregroundColor(Color.flipaGreen)
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
                    .foregroundColor(Color.flipaCoral)
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
                    .foregroundColor(Color.flipaCoral)
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
    public let onImagePicked: (UIImage, Bool) -> Void

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
