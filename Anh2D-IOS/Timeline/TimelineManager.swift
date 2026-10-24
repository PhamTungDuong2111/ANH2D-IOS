import Foundation
import UIKit
import Combine

public final class TimelineManager: ObservableObject {
    @Published public var isPlaying: Bool = false
    @Published public var isLooping: Bool = true
    @Published public var copiedFrame: Frame? = nil

    public var project: Project
    private var timer: Timer?
    private var holdCounter: Int = 0

    public var onFrameChanged: ((Int) -> Void)?
    public var onAudioTrigger: ((Int) -> Void)?

    public init(project: Project) {
        self.project = project
    }

    public func setProject(_ newProject: Project) {
        stopPlayback()
        self.project = newProject
        self.holdCounter = 0
        onFrameChanged?(project.currentFrameIndex)
    }

    public func startPlayback() {
        guard !isPlaying else { return }
        isPlaying = true
        holdCounter = 0

        let interval = 1.0 / Double(max(1, min(30, project.fps)))
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.tick()
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    public func stopPlayback() {
        isPlaying = false
        timer?.invalidate()
        timer = nil
    }

    public func togglePlayback() {
        if isPlaying {
            stopPlayback()
        } else {
            startPlayback()
        }
    }

    private func tick() {
        guard isPlaying, !project.frames.isEmpty else { return }

        let currentFrame = project.currentFrame
        let holdDuration = currentFrame?.holdDuration ?? 1

        holdCounter += 1
        if holdCounter >= holdDuration {
            holdCounter = 0
            stepNextFrame()
        }

        onAudioTrigger?(project.currentFrameIndex)
    }

    public func stepNextFrame() {
        guard !project.frames.isEmpty else { return }
        if project.currentFrameIndex < project.frames.count - 1 {
            project.currentFrameIndex += 1
        } else if isLooping {
            project.currentFrameIndex = 0
        } else {
            stopPlayback()
        }
        onFrameChanged?(project.currentFrameIndex)
    }

    public func stepPrevFrame() {
        guard !project.frames.isEmpty else { return }
        if project.currentFrameIndex > 0 {
            project.currentFrameIndex -= 1
        } else if isLooping {
            project.currentFrameIndex = project.frames.count - 1
        }
        onFrameChanged?(project.currentFrameIndex)
    }

    public func addFrame() {
        let newFrame = Frame()
        let insertIndex = min(project.currentFrameIndex + 1, project.frames.count)
        project.frames.insert(newFrame, at: insertIndex)
        project.currentFrameIndex = insertIndex
        onFrameChanged?(project.currentFrameIndex)
    }

    public func duplicateCurrentFrame() {
        guard let current = project.currentFrame else { return }
        let cloned = current.clone()
        let insertIndex = project.currentFrameIndex + 1
        project.frames.insert(cloned, at: insertIndex)
        project.currentFrameIndex = insertIndex
        onFrameChanged?(project.currentFrameIndex)
    }

    public func copyCurrentFrame() {
        guard let current = project.currentFrame else { return }
        copiedFrame = current.clone()
    }

    public func pasteFrame() -> Bool {
        guard let copied = copiedFrame else { return false }
        let newFrame = copied.clone()
        let insertIndex = min(project.currentFrameIndex + 1, project.frames.count)
        project.frames.insert(newFrame, at: insertIndex)
        project.currentFrameIndex = insertIndex
        onFrameChanged?(project.currentFrameIndex)
        return true
    }

    public func deleteCurrentFrame() -> Bool {
        guard project.frames.count > 1 else { return false }
        project.frames.remove(at: project.currentFrameIndex)
        if project.currentFrameIndex >= project.frames.count {
            project.currentFrameIndex = project.frames.count - 1
        }
        onFrameChanged?(project.currentFrameIndex)
        return true
    }

    public func setHoldDuration(_ duration: Int) {
        guard let current = project.currentFrame else { return }
        current.holdDuration = max(1, min(5, duration))
        onFrameChanged?(project.currentFrameIndex)
    }

    public func loopSequence(times: Int) {
        guard times > 0, !project.frames.isEmpty else { return }
        let currentSequence = project.frames.map { $0.clone() }
        for _ in 1..<times {
            for f in currentSequence {
                project.frames.append(f.clone())
            }
        }
        onFrameChanged?(project.currentFrameIndex)
    }
}
