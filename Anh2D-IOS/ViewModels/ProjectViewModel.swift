import SwiftUI
import Combine
import UIKit

public final class ProjectViewModel: ObservableObject {
    @Published public var project: Project
    @Published public var currentTool: ToolType = .pen
    @Published public var currentShape: ShapeType = .line
    @Published public var brushColor: Color = .black
    @Published public var brushSize: CGFloat = 8.0
    @Published public var brushOpacity: CGFloat = 1.0
    @Published public var rulerType: RulerType = .none
    @Published public var isGridVisible: Bool = false

    @Published public var isOnionSkinEnabled: Bool = true
    @Published public var onionSkinFramesBefore: Int = 1
    @Published public var onionSkinFramesAfter: Int = 1
    @Published public var onionSkinAlpha: CGFloat = 0.35
    @Published public var currentLayout: AppLayout = .classic

    // Dialog & Popout states (matching ADR)
    @Published public var showProjectsGallery: Bool = false
    @Published public var showNewProjectSheet: Bool = false
    @Published public var showAudioModal: Bool = false
    @Published public var showSettingsModal: Bool = false
    @Published public var showFpsModal: Bool = false
    @Published public var showToolOptionsPopout: Bool = false
    @Published public var showColorPickerPopout: Bool = false

    @Published public var showCanvasSettings: Bool = false
    @Published public var showLayerDrawer: Bool = false
    @Published public var showExportSheet: Bool = false
    @Published public var showChallengesDialog: Bool = false
    @Published public var showOnionSkinSettings: Bool = false
    @Published public var showShapePicker: Bool = false
    @Published public var showAllToolsPicker: Bool = false
    @Published public var showTextPrompt: Bool = false
    @Published public var textPromptInput: String = ""
    @Published public var showRotoscopingPicker: Bool = false
    @Published public var showAiVoicePrompt: Bool = false
    @Published public var aiVoiceScript: String = ""
    @Published public var activeAiVoiceTrack: AudioTrack? = nil
    @Published public var showLayerFXDialog: Bool = false
    @Published public var showLoopSequenceDialog: Bool = false
    @Published public var loopCount: Int = 2
    @Published public var toastMessage: String? = nil

    // Export progress & sharing
    @Published public var isExporting: Bool = false
    @Published public var exportProgress: String = ""
    @Published public var exportedFileURL: URL? = nil
    @Published public var showShareSheet: Bool = false
    @Published public var exportWithWatermark: Bool = true

    // Audio recording state
    @Published public var recordingTrackId: UUID? = nil
    @Published public var isRecordingMicLive: Bool = false

    // Multiple projects support
    @Published public var projectsList: [Project] = []

    public let drawingView: CanvasDrawingView
    public let timelineManager: TimelineManager
    public let audioEngine: AudioEngine
    public let aiVoiceMaker: AiVoiceMaker
    public let loc = LocalizationManager.shared

    private var cancellables = Set<AnyCancellable>()

    public init() {
        let initialProject = Project.createDefault()
        self.project = initialProject
        self.projectsList = [initialProject, Project.createSampleStickmanProject()]

        self.drawingView = CanvasDrawingView(project: initialProject)
        self.timelineManager = TimelineManager(project: initialProject)
        self.audioEngine = AudioEngine()
        self.aiVoiceMaker = AiVoiceMaker()

        setupBindings()
    }

    private func setupBindings() {
        timelineManager.onFrameChanged = { [weak self] _ in
            self?.objectWillChange.send()
            self?.drawingView.setNeedsDisplay()
        }

        timelineManager.onAudioTrigger = { [weak self] currentFrame in
            guard let self = self else { return }
            for track in self.project.audioTracks where !track.isMuted {
                if track.startFrame == currentFrame {
                    self.audioEngine.playTrack(track)
                }
            }
        }

        drawingView.onProjectChanged = { [weak self] in
            self?.objectWillChange.send()
        }
    }

    // MARK: - Projects Management (matching ADR Gallery)
    public func switchProject(to target: Project) {
        project = target
        drawingView.project = target
        timelineManager.setProject(target)
        drawingView.resetViewport()
        drawingView.setNeedsDisplay()
        showProjectsGallery = false
        showToast(loc.t("saved_successfully"))
    }

    public func createNewProject(title: String, preset: CanvasPreset, fps: Int, bgHex: String) {
        let newProj = Project.createEmpty(title: title, preset: preset, fps: fps, bgHex: bgHex)
        projectsList.insert(newProj, at: 0)
        switchProject(to: newProj)
        showNewProjectSheet = false
    }

    public func duplicateProject(target: Project) {
        let copy = target.duplicate()
        projectsList.append(copy)
        showToast("Đã nhân bản \(target.title)")
    }

    public func deleteProject(target: Project) {
        guard projectsList.count > 1 else {
            showToast("Không thể xóa dự án duy nhất!")
            return
        }
        projectsList.removeAll(where: { $0.id == target.id })
        if project.id == target.id, let first = projectsList.first {
            switchProject(to: first)
        }
        showToast("Đã xóa dự án")
    }

    public func loadSampleBall() {
        let ball = Project.createSampleBouncingBallProject()
        projectsList.insert(ball, at: 0)
        switchProject(to: ball)
    }

    public func loadSampleStickman() {
        let stick = Project.createSampleStickmanProject()
        projectsList.insert(stick, at: 0)
        switchProject(to: stick)
    }

    // MARK: - Viewport & Grid Controls
    public func zoomFit() {
        drawingView.resetViewport()
        showToast(loc.t("fit_to_screen"))
    }

    public func toggleGrid() {
        isGridVisible.toggle()
        drawingView.isGridVisible = isGridVisible
        drawingView.setNeedsDisplay()
    }

    // MARK: - Tool Dock Selection & Popouts (matching ADR)
    public func selectTool(_ tool: ToolType) {
        if tool == .pen || tool == .pencil || tool == .brush || tool == .highlighter {
            if currentTool == tool {
                showToolOptionsPopout.toggle()
            } else {
                currentTool = tool
                showToolOptionsPopout = true
            }
            showColorPickerPopout = false
        } else if tool == .eraser {
            if currentTool == .eraser {
                showToolOptionsPopout.toggle()
            } else {
                currentTool = .eraser
                showToolOptionsPopout = true
            }
            showColorPickerPopout = false
        } else if tool == .shapes {
            if currentTool == .shapes {
                showToolOptionsPopout.toggle()
            } else {
                currentTool = .shapes
                showToolOptionsPopout = true
            }
            showColorPickerPopout = false
        } else if tool == .text {
            currentTool = .text
            showTextPrompt = true
            showToolOptionsPopout = false
            showColorPickerPopout = false
        } else if tool == .bucket {
            currentTool = .bucket
            showToolOptionsPopout = false
            showColorPickerPopout = false
        } else {
            currentTool = tool
            showToolOptionsPopout = false
            showColorPickerPopout = false
        }
    }

    public func toggleColorPicker() {
        showColorPickerPopout.toggle()
        if showColorPickerPopout {
            showToolOptionsPopout = false
        }
    }

    public func clearCurrentCanvas() {
        guard let layer = project.activeLayer, !layer.isLocked, let frame = project.currentFrame else { return }
        drawingView.saveUndoSnapshot()
        let blank = UIImage.createBlank(size: project.canvasSize)
        frame.setImage(blank, for: layer.id)
        drawingView.setNeedsDisplay()
        showToast(loc.t("clear_canvas"))
    }

    // MARK: - Lasso Tools (matching ADR Floating Bar)
    public func lassoFlipH() {
        guard drawingView.lassoManager.hasSelection else { return }
        drawingView.lassoManager.flipHorizontal()
        drawingView.setNeedsDisplay()
        showToast(loc.t("lasso_flip_h"))
    }

    public func lassoDelete() {
        guard drawingView.lassoManager.hasSelection else { return }
        drawingView.lassoManager.deleteSelection()
        drawingView.setNeedsDisplay()
        showToast(loc.t("lasso_delete"))
    }

    public func lassoDone() {
        drawingView.commitLasso()
        showToast(loc.t("done"))
    }

    // MARK: - Ruler & Eyedropper Cycling
    public func cycleRuler() {
        switch rulerType {
        case .none: rulerType = .straight
        case .straight: rulerType = .circle
        case .circle: rulerType = .square
        case .square: rulerType = .none
        }
        drawingView.rulerOverlay.rulerType = rulerType
        drawingView.setNeedsDisplay()
    }

    public func toggleEyedropper() {
        if currentTool == .eyedropper {
            currentTool = .pen
        } else {
            currentTool = .eyedropper
            showToast(loc.t("eyedropper"))
        }
    }

    // MARK: - Frame Copy / Paste (matching ADR Filmstrip Actions)
    public func copyCurrentFrame() {
        timelineManager.copyCurrentFrame()
        showToast(loc.t("frame_copied"))
    }

    public func pasteFrame() {
        if timelineManager.pasteFrame() {
            showToast(loc.t("frame_pasted"))
        }
    }

    // MARK: - Undo / Redo
    public func undo() {
        drawingView.undo()
        showToast(loc.t("undo"))
    }

    public func redo() {
        drawingView.redo()
        showToast(loc.t("redo"))
    }

    public var canUndo: Bool { drawingView.canUndo }
    public var canRedo: Bool { drawingView.canRedo }

    // MARK: - Layer Management
    public func addLayer() {
        guard project.layers.count < 10 else {
            showToast("Đã đạt giới hạn tối đa 10 layer (FlipaClip Plus)")
            return
        }
        let newLayer = Layer(name: String(format: loc.t("layer_name"), project.layers.count + 1))
        project.layers.append(newLayer)
        project.activeLayerIndex = project.layers.count - 1
        drawingView.setNeedsDisplay()
        showToast("Đã thêm \(newLayer.name)")
    }

    public func deleteLayer(at index: Int) {
        guard project.layers.count > 1 else {
            showToast(loc.t("cannot_delete_last_layer"))
            return
        }
        let removed = project.layers.remove(at: index)
        if project.activeLayerIndex >= project.layers.count {
            project.activeLayerIndex = project.layers.count - 1
        }
        drawingView.setNeedsDisplay()
        showToast("Đã xóa \(removed.name)")
    }

    public func duplicateLayer(at index: Int) {
        guard project.layers.count < 10 else {
            showToast("Đã đạt giới hạn 10 layer")
            return
        }
        let target = project.layers[index]
        let duplicated = target.duplicate()
        project.layers.insert(duplicated, at: index + 1)
        project.activeLayerIndex = index + 1

        for frame in project.frames {
            if let img = frame.getImage(for: target.id) {
                frame.setImage(img, for: duplicated.id)
            }
        }
        drawingView.setNeedsDisplay()
        showToast("Đã nhân bản \(target.name)")
    }

    // MARK: - Audio Recorder Modal
    public func toggleVoiceRecording(for track: AudioTrack) {
        if recordingTrackId == track.id {
            var updated = track
            if let _ = audioEngine.stopRecording(for: &updated) {
                if let idx = project.audioTracks.firstIndex(where: { $0.id == track.id }) {
                    project.audioTracks[idx] = updated
                }
                recordingTrackId = nil
                isRecordingMicLive = false
                showToast(loc.t("voice_recorded"))
            }
        } else {
            audioEngine.startRecording(for: track) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self?.recordingTrackId = track.id
                        self?.isRecordingMicLive = true
                        self?.showToast(self?.loc.t("recording_live") ?? "Recording...")
                    case .failure(let err):
                        self?.showToast("Lỗi mic: \(err.localizedDescription)")
                    }
                }
            }
        }
    }

    public func importAudioFile(from url: URL, into track: AudioTrack) {
        var updated = track
        if audioEngine.importAudioFile(from: url, into: &updated) {
            if let idx = project.audioTracks.firstIndex(where: { $0.id == track.id }) {
                project.audioTracks[idx] = updated
            }
            showToast("Đã nạp file âm thanh thành công!")
        } else {
            showToast("Không thể mở file âm thanh")
        }
    }

    public func removeAudioFromProject() {
        for i in 0..<project.audioTracks.count {
            project.audioTracks[i].fileURL = nil
        }
        showToast(loc.t("delete_audio"))
    }

    public func generateAiVoice(script: String, for track: AudioTrack) {
        guard !script.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        showToast("Đang tạo giọng nói AI on-device...")
        var updated = track
        aiVoiceMaker.generateSpeech(text: script, into: &updated) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    if let idx = self?.project.audioTracks.firstIndex(where: { $0.id == track.id }) {
                        self?.project.audioTracks[idx] = updated
                    }
                    self?.showToast("Đã gắn giọng nói AI vào \(track.name)!")
                case .failure(let err):
                    self?.showToast("Lỗi AI Voice: \(err.localizedDescription)")
                }
            }
        }
    }

    // MARK: - Rotoscoping & Magic Cut
    public func setRotoscopingReference(image: UIImage, opacity: Float = 0.45) {
        guard let frame = project.currentFrame else { return }
        frame.referenceImage = image
        frame.referenceOpacity = opacity
        drawingView.setNeedsDisplay()
        showToast("Đã nạp ảnh tham chiếu Rotoscoping!")
    }

    public func executeMagicCutAi(on image: UIImage) {
        showToast("Đang chạy Magic Cut AI tách vật thể...")
        DispatchQueue.global(qos: .userInitiated).async {
            let cutout = MagicCutEngine.autoCutout(sourceImage: image)
            DispatchQueue.main.async { [weak self] in
                guard let self = self, let layer = self.project.activeLayer, let frame = self.project.currentFrame else { return }
                self.drawingView.saveUndoSnapshot()
                let existing = frame.getImage(for: layer.id)
                let renderer = UIGraphicsImageRenderer(size: self.project.canvasSize)
                let merged = renderer.image { _ in
                    existing?.draw(in: CGRect(origin: .zero, size: self.project.canvasSize))
                    cutout.draw(in: CGRect(origin: .zero, size: self.project.canvasSize))
                }
                frame.setImage(merged, for: layer.id)
                self.drawingView.setNeedsDisplay()
                self.showToast("Magic Cut AI hoàn tất!")
            }
        }
    }

    // MARK: - Export Movie & GIF
    public func exportVideoMp4() {
        isExporting = true
        exportProgress = loc.t("rendering")
        MovieExporter.exportMp4(
            project: project,
            onProgress: { [weak self] current, total in
                self?.exportProgress = "Khung hình \(current) / \(total)..."
            },
            completion: { [weak self] result in
                self?.isExporting = false
                switch result {
                case .success(let url):
                    self?.exportedFileURL = url
                    self?.showShareSheet = true
                    self?.showToast(self?.loc.t("export_success") ?? "Export success!")
                case .failure(let err):
                    self?.showToast("Lỗi xuất video: \(err.localizedDescription)")
                }
            }
        )
    }

    public func exportAnimatedGif() {
        isExporting = true
        exportProgress = loc.t("rendering")
        MovieExporter.exportGif(
            project: project,
            onProgress: { [weak self] current, total in
                self?.exportProgress = "Khung hình \(current) / \(total)..."
            },
            completion: { [weak self] result in
                self?.isExporting = false
                switch result {
                case .success(let url):
                    self?.exportedFileURL = url
                    self?.showShareSheet = true
                    self?.showToast(self?.loc.t("export_success") ?? "Export success!")
                case .failure(let err):
                    self?.showToast("Lỗi xuất GIF: \(err.localizedDescription)")
                }
            }
        )
    }

    public func exportPngSequence(transparent: Bool = true) {
        isExporting = true
        exportProgress = loc.t("rendering")
        MovieExporter.exportPngSequence(
            project: project,
            transparent: transparent,
            onProgress: { [weak self] current, total in
                self?.exportProgress = "Ảnh \(current) / \(total)..."
            },
            completion: { [weak self] result in
                self?.isExporting = false
                switch result {
                case .success(let dir):
                    self?.exportedFileURL = dir
                    self?.showShareSheet = true
                    self?.showToast(self?.loc.t("export_success") ?? "Export success!")
                case .failure(let err):
                    self?.showToast("Lỗi xuất PNG: \(err.localizedDescription)")
                }
            }
        )
    }

    public func showToast(_ msg: String) {
        toastMessage = msg
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
            if self?.toastMessage == msg {
                self?.toastMessage = nil
            }
        }
    }
}
