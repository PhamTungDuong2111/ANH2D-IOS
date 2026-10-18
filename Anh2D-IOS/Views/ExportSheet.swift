import SwiftUI
import UIKit

public struct ExportSheet: View {
    @ObservedObject public var viewModel: ProjectViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var transparentPng: Bool = true

    public var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Animation Overview
                VStack(spacing: 8) {
                    Image(systemName: "film.fill")
                        .font(.system(size: 40))
                        .foregroundColor(Color.flipaOrange)

                    Text(viewModel.project.title)
                        .font(.system(size: 18, weight: .bold))

                    Text("\(viewModel.project.frames.count) khung hình • \(viewModel.project.fps) FPS • \(viewModel.project.width)x\(viewModel.project.height) px")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                .padding(.top, 10)

                if viewModel.isExporting {
                    VStack(spacing: 12) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color.flipaOrange))
                            .scaleEffect(1.3)
                        Text(viewModel.exportProgress)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color.flipaOrange)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(viewModel.project.isDarkMode ? Color.flipaPanelElevated : Color(hex: "#F1F5F9"))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }

                // Export Options List
                VStack(spacing: 12) {
                    // MP4 Video
                    exportOptionCard(
                        icon: "video.fill",
                        color: Color.flipaOrange,
                        title: "Xuất Video MP4 (Chuẩn H.264 1080p)",
                        subtitle: "Độ tương thích cao cho YouTube, TikTok, Facebook",
                        action: { viewModel.exportVideoMp4() }
                    )

                    // Animated GIF
                    exportOptionCard(
                        icon: "photo.stack.fill",
                        color: Color.flipaCyan,
                        title: "Xuất Ảnh Động GIF",
                        subtitle: "Ảnh lặp chuyển động mượt mà, dễ chia sẻ qua tin nhắn",
                        action: { viewModel.exportAnimatedGif() }
                    )

                    // PNG Sequence
                    VStack(spacing: 8) {
                        exportOptionCard(
                            icon: "folder.fill",
                            color: Color.flipaNeonGreen,
                            title: "Xuất Chuỗi Ảnh PNG Sequence",
                            subtitle: "Từng khung hình sắc nét, hỗ trợ nền trong suốt",
                            action: { viewModel.exportPngSequence(transparent: transparentPng) }
                        )

                        Toggle("Hỗ trợ nền trong suốt (Transparency)", isOn: $transparentPng)
                            .font(.system(size: 12))
                            .padding(.horizontal, 8)
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
            .navigationTitle("Xuất Hoạt Hình (Export)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Đóng") {
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

    private func exportOptionCard(
        icon: String,
        color: Color,
        title: String,
        subtitle: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
                    .frame(width: 44, height: 44)
                    .background(color.opacity(0.15))
                    .cornerRadius(10)

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(viewModel.project.isDarkMode ? .white : .black)

                    Text(subtitle)
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }

                Spacer()

                Image(systemName: "arrow.down.circle.fill")
                    .font(.system(size: 18))
                    .foregroundColor(color)
            }
            .padding(12)
            .background(viewModel.project.isDarkMode ? Color.flipaPanelElevated : Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.06), radius: 4, y: 2)
        }
        .disabled(viewModel.isExporting)
    }
}

public struct ShareActivityView: UIViewControllerRepresentable {
    public let activityItems: [Any]

    public func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    public func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
