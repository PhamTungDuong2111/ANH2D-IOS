import SwiftUI
import Combine

public enum AppLanguage: String, CaseIterable, Identifiable {
    case vi = "vi"
    case en = "en"

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .vi: return "Tiếng Việt"
        case .en: return "English"
        }
    }

    public var flag: String {
        switch self {
        case .vi: return "🇻🇳"
        case .en: return "🇬🇧"
        }
    }

    public var shortCode: String {
        switch self {
        case .vi: return "VI"
        case .en: return "EN"
        }
    }
}

public final class LocalizationManager: ObservableObject {
    public static let shared = LocalizationManager()

    @Published public var currentLanguage: AppLanguage {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: "flipaclip_app_language")
        }
    }

    private let viDictionary: [String: String] = [
        // App Bar & Brand
        "app_title": "FlipaClip 2D",
        "projects": "Dự án của tôi",
        "back_to_projects": "Quay lại danh sách",
        "undo": "Hoàn tác (Ctrl+Z)",
        "redo": "Làm lại (Ctrl+Y)",
        "ruler": "Thước kẻ",
        "lasso": "Vùng chọn Lasso",
        "eyedropper": "Hút màu",
        "layers": "Lớp vẽ",
        "audio": "Âm thanh & Lồng tiếng",
        "settings": "Cài đặt & Hướng dẫn",
        "make_movie": "Tạo phim",
        "language": "Ngôn ngữ",

        // Drawing Tools
        "tool_pen": "Bút vẽ",
        "tool_pencil": "Bút chì",
        "tool_marker": "Bút dạ",
        "tool_highlighter": "Dạ quang",
        "tool_eraser": "Tẩy / Cục gôm",
        "tool_bucket": "Thùng sơn (Tô màu)",
        "tool_shapes": "Hình học & Thước",
        "tool_text": "Chèn văn bản",
        "tool_color": "Bảng màu",

        // Tool Options
        "size": "Kích thước",
        "opacity": "Độ mờ đục",
        "tolerance": "Dung sai",
        "color_palette": "Bảng màu",
        "brush_type": "Loại cọ",
        "shape_line": "Đường thẳng",
        "shape_rect": "Hình chữ nhật",
        "shape_circle": "Hình tròn",
        "shape_star": "Ngôi sao",
        "text_placeholder": "Nhập văn bản vào đây...",
        "add_text": "Đóng dấu văn bản",
        "apply": "Áp dụng",
        "cancel": "Hủy",
        "done": "Xong",
        "clear_canvas": "Xóa toàn bộ khung",

        // Lasso Transform
        "lasso_selected": "Đã chọn vùng",
        "lasso_hint": "Khoanh vùng nét vẽ để di chuyển, đổi kích cỡ hoặc lật",
        "lasso_flip_h": "Lật ngang",
        "lasso_flip_v": "Lật dọc",
        "lasso_copy": "Sao chép",
        "lasso_paste": "Dán",
        "lasso_delete": "Xóa vùng chọn",

        // Timeline & Frames
        "frame": "Khung",
        "frame_of": "/",
        "add_frame": "Thêm khung mới",
        "duplicate_frame": "Nhân đôi khung",
        "copy_frame": "Sao chép khung",
        "paste_frame": "Dán khung",
        "delete_frame": "Xóa khung",
        "clear_frame": "Làm sạch khung",
        "play": "Phát",
        "pause": "Tạm dừng",
        "loop": "Lặp lại",
        "loop_once": "Phát 1 lần",
        "onion_skin": "Onion Skin (Hành tây mờ)",
        "onion_skin_desc": "Hiển thị bóng mờ của khung trước và sau để căn chỉnh chuyển động",
        "fps": "Tốc độ khung hình (FPS)",
        "fps_hint": "12 FPS là tốc độ chuẩn cho hoạt hình 2D truyền thống",
        "current_fps": "Tốc độ: %d FPS",

        // Layers Drawer
        "layers_title": "Quản lý Lớp (Layers)",
        "add_layer": "Thêm lớp mới",
        "layer_name": "Lớp %d",
        "layer_opacity": "Độ mờ lớp",
        "layer_visible": "Hiện lớp",
        "layer_hidden": "Ẩn lớp",
        "layer_locked": "Khóa lớp",
        "layer_unlocked": "Mở khóa",
        "delete_layer": "Xóa lớp",
        "merge_down": "Gộp xuống",
        "cannot_delete_last_layer": "Không thể xóa lớp vẽ duy nhất!",

        // Audio & Voice Recorder
        "audio_title": "Âm thanh & Lồng tiếng",
        "record_voice": "Bấm để thu âm giọng nói trực tiếp",
        "stop_recording": "Dừng thu âm",
        "upload_audio": "Tải file âm thanh (MP3, WAV)",
        "audio_track": "Dải âm thanh",
        "delete_audio": "Xóa âm thanh",
        "recording_live": "Đang ghi âm giọng nói...",

        // Export & Make Movie
        "movie_title": "Tạo phim & Xuất hoạt hình",
        "format": "Định dạng xuất",
        "format_gif": "Ảnh GIF (.gif)",
        "format_gif_sub": "Thích hợp chia sẻ nhanh",
        "format_video": "Video MP4 (.mp4)",
        "format_video_sub": "Chuẩn H.264 kèm âm thanh",
        "format_png": "Chuỗi ảnh PNG (.png)",
        "format_png_sub": "Độ phân giải nguyên bản",
        "watermark": "Hiển thị logo FlipaClip",
        "render_button": "Bắt đầu xuất video",
        "rendering": "Đang dựng hoạt hình... Vui lòng chờ",
        "export_success": "Xuất hoạt hình thành công!",

        // Projects Management
        "my_projects": "Dự án của tôi",
        "new_project": "Tạo dự án mới",
        "project_title": "Tên dự án",
        "project_title_placeholder": "Hoạt hình của tôi...",
        "choose_canvas": "Kích thước khung hình",
        "canvas_yt": "YouTube (16:9 - 1280x720)",
        "canvas_tiktok": "TikTok / Reels (9:16 - 720x1280)",
        "canvas_insta": "Instagram (1:1 - 720x720)",
        "canvas_standard": "Chuẩn 4:3 (960x720)",
        "choose_bg": "Nền canvas",
        "bg_white": "Trắng trơn",
        "bg_paper": "Giấy vẽ phác thảo",
        "bg_grid": "Giấy kẻ ô",
        "bg_dark": "Nền tối",
        "bg_chalkboard": "Bảng đen phấn trắng",
        "frames_count": "%d khung hình",
        "open_project": "Mở",
        "duplicate_project": "Nhân bản",
        "delete_project": "Xóa",
        "sample_bouncing_ball": "Mẫu: Quả bóng nảy",
        "sample_stickman": "Mẫu: Người que chạy",

        // Settings & Guides
        "settings_title": "Cài đặt ứng dụng",
        "grid_toggle": "Bật/Tắt Lưới căn chỉnh",
        "onion_settings": "Tùy chỉnh Onion Skin",
        "fit_to_screen": "Vừa màn hình",
        "help_guide": "Hướng dẫn vẽ hoạt hình",
        "guide_intro": "FlipaClip giúp bạn tạo hoạt hình 2D từng khung hình dễ dàng như lật một cuốn sổ tay vẽ!",
        "guide_step1": "1. Vẽ hình dáng ban đầu ở khung số 1.",
        "guide_step2": "2. Bấm nút '+' ở thanh dòng thời gian phía dưới để thêm khung tiếp theo.",
        "guide_step3": "3. Bật tính năng 'Onion Skin' để thấy bóng mờ của khung trước đó và vẽ chuyển động tiếp theo.",
        "guide_step4": "4. Nhấn nút 'Phát' (Play) để xem tác phẩm hoạt hình của bạn sống động chuyển động!",
        "guide_step5": "5. Bấm 'Tạo phim' để xuất thành video MP4 hoặc GIF chia sẻ lên mạng xã hội."
    ]

    private let enDictionary: [String: String] = [
        // App Bar & Brand
        "app_title": "FlipaClip 2D",
        "projects": "My Projects",
        "back_to_projects": "Back to Projects",
        "undo": "Undo (Ctrl+Z)",
        "redo": "Redo (Ctrl+Y)",
        "ruler": "Ruler",
        "lasso": "Lasso Tool",
        "eyedropper": "Eyedropper",
        "layers": "Layers",
        "audio": "Audio & Voiceover",
        "settings": "Settings & Guide",
        "make_movie": "Make Movie",
        "language": "Language",

        // Drawing Tools
        "tool_pen": "Pen",
        "tool_pencil": "Pencil",
        "tool_marker": "Marker",
        "tool_highlighter": "Highlighter",
        "tool_eraser": "Eraser",
        "tool_bucket": "Paint Bucket",
        "tool_shapes": "Shapes & Ruler",
        "tool_text": "Insert Text",
        "tool_color": "Color Palette",

        // Tool Options
        "size": "Size",
        "opacity": "Opacity",
        "tolerance": "Tolerance",
        "color_palette": "Palette",
        "brush_type": "Brush Type",
        "shape_line": "Line",
        "shape_rect": "Rectangle",
        "shape_circle": "Circle",
        "shape_star": "Star",
        "text_placeholder": "Type text here...",
        "add_text": "Stamp Text",
        "apply": "Apply",
        "cancel": "Cancel",
        "done": "Done",
        "clear_canvas": "Clear Canvas",

        // Lasso Transform
        "lasso_selected": "Area Selected",
        "lasso_hint": "Lasso around drawings to move, scale, rotate, or flip",
        "lasso_flip_h": "Flip Horizontal",
        "lasso_flip_v": "Flip Vertical",
        "lasso_copy": "Copy",
        "lasso_paste": "Paste",
        "lasso_delete": "Delete Selection",

        // Timeline & Frames
        "frame": "Frame",
        "frame_of": "/",
        "add_frame": "Add Frame",
        "duplicate_frame": "Duplicate Frame",
        "copy_frame": "Copy Frame",
        "paste_frame": "Paste Frame",
        "delete_frame": "Delete Frame",
        "clear_frame": "Clear Frame",
        "play": "Play",
        "pause": "Pause",
        "loop": "Loop",
        "loop_once": "Play Once",
        "onion_skin": "Onion Skin",
        "onion_skin_desc": "Shows ghost silhouettes of adjacent frames to guide movement",
        "fps": "FPS (Frames Per Second)",
        "fps_hint": "12 FPS is standard for traditional 2D hand-drawn animation",
        "current_fps": "Speed: %d FPS",

        // Layers Drawer
        "layers_title": "Layers Manager",
        "add_layer": "Add Layer",
        "layer_name": "Layer %d",
        "layer_opacity": "Layer Opacity",
        "layer_visible": "Show Layer",
        "layer_hidden": "Hide Layer",
        "layer_locked": "Lock Layer",
        "layer_unlocked": "Unlock Layer",
        "delete_layer": "Delete Layer",
        "merge_down": "Merge Down",
        "cannot_delete_last_layer": "Cannot delete the only remaining layer!",

        // Audio & Voice Recorder
        "audio_title": "Audio & Voiceover",
        "record_voice": "Tap to record voiceover live",
        "stop_recording": "Stop Recording",
        "upload_audio": "Upload Audio File (MP3, WAV)",
        "audio_track": "Audio Track",
        "delete_audio": "Delete Audio",
        "recording_live": "Recording voiceover live...",

        // Export & Make Movie
        "movie_title": "Make Movie & Export Animation",
        "format": "Export Format",
        "format_gif": "Animated GIF (.gif)",
        "format_gif_sub": "Best for quick sharing",
        "format_video": "Video MP4 (.mp4)",
        "format_video_sub": "H.264 with audio track",
        "format_png": "PNG Sequence (.png)",
        "format_png_sub": "Full native resolution",
        "watermark": "FlipaClip Logo Watermark",
        "render_button": "Render Movie",
        "rendering": "Rendering animation... Please wait",
        "export_success": "Export successful!",

        // Projects Management
        "my_projects": "My Projects",
        "new_project": "New Project",
        "project_title": "Project Name",
        "project_title_placeholder": "My Animation...",
        "choose_canvas": "Canvas Preset",
        "canvas_yt": "YouTube (16:9 - 1280x720)",
        "canvas_tiktok": "TikTok / Reels (9:16 - 720x1280)",
        "canvas_insta": "Instagram (1:1 - 720x720)",
        "canvas_standard": "Classic 4:3 (960x720)",
        "choose_bg": "Canvas Background",
        "bg_white": "Plain White",
        "bg_paper": "Sketch Paper",
        "bg_grid": "Grid Paper",
        "bg_dark": "Dark Slate",
        "bg_chalkboard": "Chalkboard",
        "frames_count": "%d frames",
        "open_project": "Open",
        "duplicate_project": "Duplicate",
        "delete_project": "Delete",
        "sample_bouncing_ball": "Sample: Bouncing Ball",
        "sample_stickman": "Sample: Running Stickman",

        // Settings & Guides
        "settings_title": "Application Settings",
        "grid_toggle": "Alignment Grid Overlay",
        "onion_settings": "Onion Skin Settings",
        "fit_to_screen": "Fit Screen",
        "help_guide": "Animation Guide",
        "guide_intro": "FlipaClip lets you create frame-by-frame 2D animation just like flipping through a sketchbook!",
        "guide_step1": "1. Draw your character on Frame 1.",
        "guide_step2": "2. Tap '+' on the bottom timeline to add the next frame.",
        "guide_step3": "3. Turn on 'Onion Skin' to see the ghost outlines of previous drawings.",
        "guide_step4": "4. Press Play to see your animation come alive in real time!",
        "guide_step5": "5. Tap 'Make Movie' to export to MP4 or GIF and share your work."
    ]

    public init() {
        let saved = UserDefaults.standard.string(forKey: "flipaclip_app_language") ?? "vi"
        self.currentLanguage = AppLanguage(rawValue: saved) ?? .vi
    }

    public func t(_ key: String) -> String {
        switch currentLanguage {
        case .vi:
            return viDictionary[key] ?? enDictionary[key] ?? key
        case .en:
            return enDictionary[key] ?? viDictionary[key] ?? key
        }
    }

    public func toggleLanguage() {
        currentLanguage = (currentLanguage == .vi) ? .en : .vi
    }
}
