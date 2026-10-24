import SwiftUI
import UIKit

public struct ExportSheet: View {
    @ObservedObject public var viewModel: ProjectViewModel
    @ObservedObject private var loc = LocalizationManager.shared
    @Environment(\.presentationMode) var presentationMode

    enum ExportFormat: String, CaseIterable {
        case gif = "gif"
        case video = "video"
        case png = "png"
    }

    @State private var selectedFormat: ExportFormat = .gif
    @State private var watermark: Bool = true

    public var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Format Selection Grid (matching ADR .presets-grid)
                VStack(alignment: .leading, spacing: 8) {
                    Text(loc.t("format"))
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(viewModel.project.isDarkMode ? .white : .black)

                    HStack(spacing: 8) {
                        formatCard(
                            format: .gif,
                            title: loc.t("format_gif"),
                            subtitle: loc.t("format_gif_sub"),
                            icon: "photo.stack.fill"
                        )
                        formatCard(
                            format: .video,
                            title: loc.t("format_video"),
                            subtitle: loc.t("format_video_sub"),
                            icon: "video.fill"
                        )
                        formatCard(
                            format: .png,
                            title: loc.t("format_png"),
                            subtitle: loc.t("format_png_sub"),
                            icon: "folder.fill"
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)

                // Watermark Checkbox (matching ADR #export-watermark)
                Toggle(isOn: $watermark) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(Color.flipaCoral)
                        Text(loc.t("watermark"))
                            .font(.system(size: 13, weight: .medium))
                    }
                }
                .padding(.horizontal)

                // Project specs summary
                HStack(spacing: 12) {
                    Label("\(viewModel.project.frames.count) frames", systemImage: "film")
                    Label("\(viewModel.project.fps) FPS", systemImage: "speedometer")
                    Label("\(viewModel.project.width)x\(viewModel.project.height)", systemImage: "aspectratio")
                }
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundColor(.gray)
                .padding(.horizontal)

                Spacer()

                // Progress Bar (matching ADR #export-progress-container)
                if viewModel.isExporting {
                    VStack(spacing: 8) {
                        Text(viewModel.exportProgress.isEmpty ? loc.t("rendering") : viewModel.exportProgress)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color.flipaCoral)

                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color.flipaCoral))
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(viewModel.project.isDarkMode ? Color.flipaPanelElevated : Color(hex: "#F1F5F9"))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }

                // Render Action Button (matching ADR #btn-start-export)
                Button(action: {
                    startExport()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.down.circle.fill")
                            .font(.system(size: 16, weight: .bold))
                        Text(loc.t("render_button"))
                            .font(.system(size: 14, weight: .bold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(LinearGradient(
                        colors: [Color.flipaCoral, Color(hex: "#FF3B30")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shadow(color: Color.flipaCoral.opacity(0.4), radius: 8, y: 3)
                }
                .disabled(viewModel.isExporting)
                .padding(.horizontal)
                .padding(.bottom, 12)
            }
            .navigationTitle(loc.t("movie_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(loc.t("cancel")) {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $viewModel.showShareSheet) {
            if let fileURL = viewModel.exportedFileURL {
                ShareActivityView(activityItems: [fileURL])
            }
        }
    }

    private func formatCard(format: ExportFormat, title: String, subtitle: String, icon: String) -> some View {
        let isSelected = (selectedFormat == format)
        return Button(action: {
            selectedFormat = format
        }) {
            VStack(alignment: .leading, spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(isSelected ? Color.flipaCoral : .gray)

                Text(title)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(viewModel.project.isDarkMode ? .white : .black)
                    .lineLimit(1)

                Text(subtitle)
                    .font(.system(size: 9))
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(10)
            .background(isSelected ? (viewModel.project.isDarkMode ? Color.flipaCoral.opacity(0.15) : Color(hex: "#FFF0F0")) : (viewModel.project.isDarkMode ? Color.flipaPanelElevated : Color(hex: "#F8FAFC")))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.flipaCoral : Color.gray.opacity(0.2), lineWidth: isSelected ? 2 : 1)
            )
        }
    }

    private func startExport() {
        switch selectedFormat {
        case .gif:
            viewModel.exportAnimatedGif()
        case .video:
            viewModel.exportVideoMp4()
        case .png:
            viewModel.exportPngSequence(transparent: !watermark)
        }
    }
}

public struct ShareActivityView: UIViewControllerRepresentable {
    public let activityItems: [Any]

    public func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    public func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
