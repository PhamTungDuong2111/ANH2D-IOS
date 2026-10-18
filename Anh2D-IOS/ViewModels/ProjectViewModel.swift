import SwiftUI
import Combine
import UIKit

public final class ProjectViewModel: ObservableObject {
    @Published public var project: Project
    @Published public var currentTool: ToolType = .pen
    @Published public var currentShape: ShapeType = .line
    @Published public var brushColor: Color = .black
    @Published public var brushSize: CGFloat = 10.0
    @Published public var brushOpacity: CGFloat = 1.0
    @Published public var rulerType: RulerType = .none

    @Published public var isOnionSkinEnabled: Bool = true
    @Published public var onionSkinFramesBefore: Int = 1
    @Published public var onionSkinFramesAfter: Int = 1
    @Published public var currentLayout: AppLayout = .studio

    // Dialog & Sheet states
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

    // Audio recording state
    @Published public var recordingTrackId: UUID? = nil

    public let drawingView: CanvasDrawingView
    public let timelineManager: TimelineManager
    public let audioEngine: AudioEngine
    public let aiVoiceMaker: AiVoiceMaker

    private var cancellables = Set<AnyCancellable>()

    public init() {
        let initialProject = Project.createDefault()
        self.project = initialProject
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

    // MARK: - Undo / Redo
    public func undo() {
        drawingView.undo()
        showToast("Đã hoàn tác")
    }

    public func redo() {
        drawingView.redo()
        showToast("Đã làm lại")
    }

    public var canUndo: Bool { drawingView.canUndo }
    public var canRedo: Bool { drawingView.canRedo }

    // MARK: - Layer Management
    public func addLayer() {
        guard project.layers.count < 10 else {
            showToast("Đã đạt giới hạn tối đa 10 layer (FlipaClip Plus)")
            return
        }
        let newLayer = Layer(name: "Layer \(project.layers.count + 1)")
        project.layers.append(newLayer)
        project.activeLayerIndex = project.layers.count - 1
        drawingView.setNeedsDisplay()
        showToast("Đã thêm \(newLayer.name)")
    }

    public func deleteLayer(at index: Int) {
        guard project.layers.count > 1 else {
            showToast("Phải giữ lại ít nhất 1 layer")
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

        // Copy drawings in all frames
        for frame in project.frames {
            if let img = frame.getImage(for: target.id) {
                frame.setImage(img, for: duplicated.id)
            }
        }
        drawingView.setNeedsDisplay()
        showToast("Đã nhân bản \(target.name)")
    }

    // MARK: - Audio Studio
    public func addAudioTrack() {
        guard project.audioTracks.count < 6 else {
            showToast("Bản miễn phí hỗ trợ tối đa 6 audio track")
            return
        }
        let track = AudioTrack(name: "Audio \(project.audioTracks.count + 1)")
        project.audioTracks.append(track)
        showToast("Đã thêm \(track.name)")
    }

    public func toggleVoiceRecording(for track: AudioTrack) {
        if recordingTrackId == track.id {
            // Stop recording
            var updated = track
            if let url = audioEngine.stopRecording(for: &updated) {
                if let idx = project.audioTracks.firstIndex(where: { $0.id == track.id }) {
                    project.audioTracks[idx] = updated
                }
                recordingTrackId = nil
                showToast("Đã thu âm lồng tiếng!")
            }
        } else {
            // Start recording
            audioEngine.startRecording(for: track) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self?.recordingTrackId = track.id
                        self?.showToast("Đang ghi âm...")
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
            showToast("Đã nhập âm thanh vào \(track.name)")
        } else {
            showToast("Không thể nhập file âm thanh")
        }
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

    // MARK: - Rotoscoping Reference & Magic Cut AI
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
        exportProgress = "Đang khởi tạo video H.264..."
        MovieExporter.exportMp4(
            project: project,
            onProgress: { [weak self] current, total in
                self?.exportProgress = "Đang kết xuất khung hình \(current) / \(total)..."
            },
            completion: { [weak self] result in
                self?.isExporting = false
                switch result {
                case .success(let url):
                    self?.exportedFileURL = url
                    self?.showShareSheet = true
                    self?.showToast("Xuất video MP4 thành công!")
                case .failure(let err):
                    self?.showToast("Lỗi xuất video: \(err.localizedDescription)")
                }
            }
        )
    }

    public func exportAnimatedGif() {
        isExporting = true
        exportProgress = "Đang mã hóa ảnh động GIF..."
        MovieExporter.exportGif(
            project: project,
            onProgress: { [weak self] current, total in
                self?.exportProgress = "Đang nén khung hình \(current) / \(total)..."
            },
            completion: { [weak self] result in
                self?.isExporting = false
                switch result {
                case .success(let url):
                    self?.exportedFileURL = url
                    self?.showShareSheet = true
                    self?.showToast("Xuất ảnh GIF thành công!")
                case .failure(let err):
                    self?.showToast("Lỗi xuất GIF: \(err.localizedDescription)")
                }
            }
        )
    }

    public func exportPngSequence(transparent: Bool = true) {
        isExporting = true
        exportProgress = "Đang lưu chuỗi ảnh PNG..."
        MovieExporter.exportPngSequence(
            project: project,
            transparent: transparent,
            onProgress: { [weak self] current, total in
                self?.exportProgress = "Đang lưu ảnh \(current) / \(total)..."
            },
            completion: { [weak self] result in
                self?.isExporting = false
                switch result {
                case .success(let dir):
                    self?.exportedFileURL = dir
                    self?.showShareSheet = true
                    self?.showToast("Xuất chuỗi ảnh PNG thành công!")
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
