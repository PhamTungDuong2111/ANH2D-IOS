# FlipaClip 2D: Draw 2D Animation (iOS - Swift Native)

Ứng dụng vẽ và làm hoạt hình 2D dạng kịch bản khung hình (**frame-by-frame**) chuyên nghiệp dành riêng cho hệ điều hành iOS (iPhone & iPad), được xây dựng hoàn toàn bằng **Native Swift & SwiftUI / UIKit** với đầy đủ 100% tính năng tương đương bản Android theo chuẩn [FlipaClip: Draw 2D Animation (App Store ID: 1101848914)](https://apps.apple.com/us/app/flipaclip-draw-2d-animation/id1101848914).

- **GitHub Repository**: [https://github.com/PhamTungDuong2111/ANH2D-IOS.git](https://github.com/PhamTungDuong2111/ANH2D-IOS.git)
- **Công nghệ nền tảng**: Swift 5.0+, SwiftUI, UIKit, CoreGraphics, ImageIO, AVFoundation, Vision AI
- **Thiết bị hỗ trợ**: iPhone & iPad (tương thích iOS 16.0 trở lên, hỗ trợ Apple Pencil nhận diện lực nhấn và độ nghiêng)

---

## 🎨 Danh Sách Tính Năng Nổi Bật (100% Đồng Bộ Chuẩn FlipaClip)

### 1. Bộ Công Cụ Vẽ Đa Dạng (Art Tools)
- **Đầy đủ 12 loại cọ & công cụ vẽ chuyên sâu**:
  - **Bút mực (Pen)**: Nét mực chuẩn xác, làm mượt đường cong tự động (`addQuadCurve`).
  - **Bút chì (Pencil)**: Phác thảo tự nhiên với kết cấu nét chì.
  - **Cọ vẽ (Brush)**: Nét vẽ mềm với hiệu ứng bóng mờ (soft edge).
  - **Dạ quang (Highlighter)**: Nét dẹt trong mờ, giữ nguyên nét vẽ bên dưới.
  - **Cục tẩy (Eraser)**: Xóa trong suốt trực tiếp với chế độ `CGBlendMode.clear`.
  - **Đổ màu thông minh (Fill Bucket)**: Thuật toán quét điểm ảnh BFS/Scanline Flood Fill với dung sai (tolerance) thông minh.
  - **Chọn vùng tự do (Lasso Tool)**: Khoanh vùng đa giác, trích xuất vùng vẽ, di chuyển bounding box, lật ngang (Flip Horizontal), lật dọc (Flip Vertical), nhân bản và đóng dấu.
  - **Thước kẻ chuẩn xác (Ruler Guides)**: Thước thẳng (Straight ruler), Thước tròn (Circle ruler), Thước vuông (Square ruler) có tính năng tự động hít điểm (Snap points).
  - **Chèn văn bản (Text Tool)**: Đóng dấu chữ ký, tiêu đề trực tiếp lên layer với phông chữ sắc nét.
  - **Hình học (Shapes)**: Đường thẳng, Hình chữ nhật, Hình tròn / Ellipse, Ngôi sao 5 cánh.
  - **Làm mịn (Smudge)**: Hòa màu và tán đều các mảng màu trên canvas.
  - **Làm mờ (Blur)**: Làm mờ cục bộ vùng vẽ.
- **Hỗ trợ bút cảm ứng (Apple Pencil & Stylus)**:
  - Nhận diện lực nhấn (`touch.force`) điều chỉnh độ dày nét vẽ linh hoạt từ 30% đến 180%.
  - Nhận diện độ nghiêng (`touch.altitudeAngle`).
  - Chế độ từ chối lòng bàn tay (**Palm Rejection / Stylus-Only Mode**) giúp kê tay thoải mái lên màn hình iPad/iPhone.
- **Bảng màu & Nét vẽ**: Tích hợp iOS `ColorPicker`, chỉnh kích thước nét từ 1px đến 60px và độ trong suốt từ 10% đến 100%.
- **Hoàn tác / Làm lại (Undo / Redo)**: Bộ nhớ đệm lưu trữ tới 25 bước lịch sử thao tác.
- **Điều hướng không gian (Pan & Zoom)**: Thu phóng 2 ngón tay từ 0.2x đến 10.0x, kéo cuộn mượt mà và nút Fit to Screen.

---

### 2. Quản Lý Lớp (Layers) & Hiệu Ứng Thị Giác (Visual FX)
- **Hỗ trợ lên tới 10 lớp vẽ** (mở khóa đầy đủ FlipaClip Plus): Thêm lớp, đổi tên, ẩn/hiện mắt layer, khóa lớp chống vẽ nhầm, nhân bản và xóa lớp.
- **Thanh trượt độ mờ đục (Opacity Slider)**: Từ 0% đến 100% cho từng lớp riêng biệt.
- **Chế độ hòa trộn (Blend Modes)**:
  - `Normal`
  - `Multiply`
  - `Screen`
  - `Overlay`
  - `Darken`
  - `Lighten`
  - `Add / Plus`
  - `Color Dodge`
- **Mặt nạ cắt (Clipping Mask)**: Cắt giới hạn nét vẽ theo hình dạng của lớp nằm ngay bên dưới (`CGBlendMode.sourceAtop`).
- **Khóa kênh trong suốt (Alpha Lock)**: Chỉ tô vẽ trên các pixel màu đã có sẵn của lớp, không lem ra nền trống.
- **Bộ 3 hiệu ứng lớp thị giác (Layer Visual FX)**:
  - **Phát sáng (Glow FX)**: Tùy chỉnh bán kính sáng và màu sắc vầng hào quang.
  - **Làm mờ ống kính (Blur FX)**: Hiệu ứng nhòe Gaussian Blur mượt mà.
  - **Mosaic Retro 8-bit (Pixel Effect)**: Biến lớp vẽ thành tranh điểm ảnh retro cổ điển (1x, 4x, 8x, 16x).

---

### 3. Hoạt Hình Khung Hình (Frame-by-Frame Animation)
- **Hành tây mờ (Onion Skin)**:
  - Bật/tắt nhanh bằng nút toggle trên thanh tiêu đề.
  - Tùy chỉnh số lượng khung hình trước (1 - 5 frames, nhuộm màu đỏ/cam).
  - Tùy chỉnh số lượng khung hình sau (1 - 5 frames, nhuộm màu xanh lá).
  - Điều chỉnh độ trong suốt mờ ảo của các bóng khung hình.
- **Dòng thời gian (Timeline & Scrubber)**:
  - Thanh cuộn ảnh thu nhỏ (thumbnails) thời gian thực hiển thị chỉ số frame `1 / N`.
  - Phát hoạt hình mượt mà đúng tốc độ FPS cài đặt.
  - Nút tua từng frame trước/sau (`Step Prev` / `Step Next`).
  - Thêm frame (+), Nhân bản frame hiện tại (`Duplicate Frame`).
  - **Kéo dài khung hình (Hold Duration)**: Giữ khung hình từ 1x đến 5x thời lượng mà không cần copy nhiều lần.
  - **Lặp chuỗi khung hình (Loop Sequence)**: Tự động nhân bản chuỗi chuyển động lặp lại tuần hoàn.
  - Xóa khung hình an toàn.
- **Hình tham chiếu (Rotoscoping)**: Nhập ảnh từ thư viện vào làm nền tham khảo với thanh trượt chỉnh độ mờ (Reference Opacity) để vẽ đè theo chuyển động người thật.

---

### 4. Biên Tập Âm Thanh Đa Tầng (Multi-layer Audio Studio)
- Hỗ trợ tối đa **6 dải âm thanh** độc lập trên cùng một dự án.
- **Ghi âm trực tiếp (Voice Recorder)**: Thu âm giọng nói, lồng tiếng trực tiếp bằng microphone điện thoại qua `AVAudioRecorder`.
- **Nhập file âm thanh (Import Audio)**: Nhập nhạc nền, sound effects định dạng MP3, WAV, M4A vào timeline.
- **Hiển thị sóng âm trực quan (Waveform Visualizer)**: Biểu diễn biên độ sóng âm đồng bộ theo thời gian.
- **Đồng bộ hóa playback**: Tự động phát âm thanh khớp từng khung hình hoạt hình khi bấm Play.
- **Tạo giọng nói AI (AI Voice Maker)**: Nhập văn bản kịch bản thoại, hệ thống tự động tổng hợp giọng nói on-device bằng `AVSpeechSynthesizer` và gắn trực tiếp vào dải âm thanh.

---

### 5. Công Cụ Trí Tuệ Nhân Tạo (Magic Cut AI)
- Tự động nhận diện và cắt chủ thể/nhân vật ra khỏi nền ảnh bằng mô hình Vision AI (`VNGenerateForegroundInstanceMaskRequest`) trên iOS 17+ và thuật toán Flood Boundary Cutout on-device.
- Tạo nhanh sticker nhân vật đưa vào các khung hình mà không cần tẩy xóa thủ công.

---

### 6. Trình Xuất Hoạt Hình & Chia Sẻ (Export & Share)
- **Xuất Video MP4**: Sử dụng phần cứng `AVAssetWriter` mã hóa H.264 độ phân giải cao (1080p/720p) đúng FPS thiết lập.
- **Xuất Ảnh Động GIF**: Tạo file `.gif` chuyển động lặp vô hạn bằng thư viện `ImageIO`.
- **Xuất Chuỗi Ảnh PNG Sequence**: Xuất toàn bộ các frame ảnh tĩnh (hỗ trợ nền trong suốt Transparency) vào thư mục.
- **Chia sẻ tức thì (Share Sheet)**: Tích hợp `UIActivityViewController` chia sẻ qua AirDrop, Lưu vào Ảnh (Photos), Tệp (Files), Tin nhắn, hoặc các mạng xã hội.

---

### 7. Giao Diện & Tùy Biến Dự Án (Layouts & Themes)
- **Chế độ giao diện kép**:
  - **Classic Mode**: Tối ưu không gian vẽ toàn màn hình với thanh công cụ nổi tinh gọn.
  - **Studio Mode**: Mở rộng bàn trộn âm thanh đa tầng và bảng timeline chi tiết.
- **Chế độ Sáng / Tối (Dark / Light Theme)**: Đổi giao diện linh hoạt phù hợp với mắt làm việc ban ngày hoặc ban đêm.
- **Tùy biến Canvas**:
  - YouTube 720p (16:9 - 1280x720)
  - YouTube 1080p (16:9 - 1920x1080)
  - TikTok / Reels / Shorts (9:16 - 1080x1920)
  - Instagram Post (1:1 - 1080x1080)
  - Classic Standard (4:3 - 1440x1080)
- **Vẽ ngoài khung hình (Draw Outside Canvas)**: Cho phép vẽ nháp, phác thảo ở vùng xám bên ngoài khung hình canvas chính.
- **Cộng đồng & Thử thách tuần (Weekly Animation Challenges)**: Tích hợp các cuộc thi hoạt hình hấp dẫn ("Walk Cycle Battle", "Stickman Stunts", "Morphing Madness") với tính năng nộp bài thi hoạt hình.

---

## 📁 Cấu Trúc Mã Nguồn Dự Án

```
Anh2D-IOS/
├── Anh2D-IOS.xcodeproj/
│   └── project.pbxproj                     # Tệp cấu hình dự án Xcode chuẩn
├── Anh2D-IOS/
│   ├── App/
│   │   ├── Anh2DApp.swift                  # Entry point SwiftUI (@main)
│   │   ├── ContentView.swift               # Giao diện chính kết hợp thanh điều hướng, dock vẽ & timeline
│   │   └── Info.plist                      # Cấu hình quyền Microphone, Photos & Camera
│   ├── Models/
│   │   ├── Enums.swift                     # Định nghĩa ToolType, ShapeType, BlendMode, Preset, Layout
│   │   ├── Layer.swift                     # Cấu trúc Layer (opacity, blendMode, clippingMask, alphaLock, FX)
│   │   ├── Frame.swift                     # Khung hình, lưu trữ bitmap layers & kết xuất composite
│   │   ├── AudioTrack.swift                # Dải âm thanh, sóng âm, volume & mute
│   │   └── Project.swift                   # Quản lý toàn bộ dự án hoạt hình
│   ├── ViewModels/
│   │   └── ProjectViewModel.swift          # ObservableObject trung tâm điều phối trạng thái ứng dụng
│   ├── Drawing/
│   │   ├── CanvasDrawingView.swift         # View vẽ UIKit hiệu năng cao hỗ trợ cảm ứng & Apple Pencil
│   │   ├── StylusTouchHelper.swift         # Nhận diện lực nhấn (force/pressure), độ nghiêng & Palm Rejection
│   │   ├── FloodFill.swift                 # Thuật toán đổ màu BFS trên buffer 32-bit RGBA
│   │   ├── LassoManager.swift              # Công cụ khoanh vùng tự do, di chuyển, lật & cắt dán
│   │   └── RulerOverlay.swift              # Thước kẻ tương tác (thẳng, tròn, vuông) với snap points
│   ├── Timeline/
│   │   ├── TimelineManager.swift           # Động cơ phát hoạt hình FPS, hold frame & lặp chuỗi
│   │   └── FrameThumbnailRenderer.swift    # Kết xuất ảnh thu nhỏ hiển thị trên thanh cuộn
│   ├── Audio/
│   │   ├── AudioEngine.swift               # Thu âm mic, nhập file nhạc & đồng bộ timeline playback
│   │   └── AiVoiceMaker.swift              # Tạo giọng nói AI on-device qua AVSpeechSynthesizer
│   ├── AI/
│   │   └── MagicCutEngine.swift            # Công cụ AI tách nền vật thể (Vision Framework & Edge Flood)
│   ├── Export/
│   │   ├── MovieExporter.swift             # Kết xuất MP4 (H.264 AVAssetWriter), GIF & PNG Sequence
│   │   └── AnimatedGifEncoder.swift        # Mã hóa file GIF động lặp vô hạn qua ImageIO
│   ├── Views/
│   │   ├── TopNavigationBar.swift          # Thanh điều hướng trên cùng (Undo, Onion, Presets, Export...)
│   │   ├── ToolDockView.swift              # Dock công cụ vẽ nổi bên trái (Pen, Eraser, Bucket, Color...)
│   │   ├── TimelineView.swift              # Bảng timeline dưới đáy (Play, Add, Hold, Dupe, Scrubber)
│   │   ├── AudioStudioView.swift           # Bàn trộn âm thanh đa tầng Studio Mode
│   │   ├── LayerDrawerView.swift           # Bảng quản lý lớp vẽ trượt từ cạnh phải
│   │   ├── CanvasSettingsSheet.swift       # Hộp thoại đổi tỷ lệ khung hình, FPS, Palm Rejection
│   │   ├── ChallengesDialog.swift          # Hộp thoại cuộc thi & sự kiện cộng đồng tuần
│   │   ├── DialogSheets.swift              # Các modal: Onion Skin, Shapes, Tools, Layer FX, Text, AI Voice
│   │   └── ExportSheet.swift               # Hộp thoại xuất file & chia sẻ qua iOS Share Sheet
│   ├── Utilities/
│   │   ├── Color+Extensions.swift          # Bộ chuyển đổi màu HEX & bảng màu thiết kế FlipaClip
│   │   └── UIImage+Effects.swift           # Bộ lọc làm mờ, pixelate 8-bit, nhuộm màu & thay đổi kích thước
│   └── Assets.xcassets/                    # Tài nguyên icon và màu sắc ứng dụng
├── .gitignore                              # File bỏ qua các thư mục tạm của Xcode & macOS
└── README.md
```

---

## 🚀 Hướng Dẫn Mở Bằng Xcode & Build Lên iPhone Thật

### 1. Chuẩn bị
- Máy Mac cài đặt **macOS Monterey, Ventura, Sonoma hoặc mới hơn**.
- Đã cài đặt **Xcode 14 / 15 / 16** từ Mac App Store hoặc [developer.apple.com](https://developer.apple.com).
- Một chiếc iPhone thật (iOS 16.0+) và cáp Lightning / Type-C kết nối với máy Mac.

### 2. Các bước khởi chạy dự án:

1. **Tải hoặc Clone mã nguồn**:
   ```bash
   git clone https://github.com/PhamTungDuong2111/ANH2D-IOS.git
   cd ANH2D-IOS
   ```

2. **Mở dự án trong Xcode**:
   - Nhấp đúp chuột vào tệp `Anh2D-IOS.xcodeproj` (hoặc chạy lệnh terminal: `open Anh2D-IOS.xcodeproj`).

3. **Cấu hình chứng chỉ ký (Signing & Capabilities)**:
   - Trong giao diện Xcode, nhấp vào tên dự án **`Anh2D-IOS`** ở thanh điều hướng cây thư mục bên trái (biểu tượng Blueprint màu xanh).
   - Chọn tab **`Signing & Capabilities`**.
   - Tại mục **`Team`**, chọn tài khoản Apple ID cá nhân của bạn (**Personal Team** miễn phí).
   - Xcode sẽ tự động tạo cấu hình *Provisioning Profile* cho máy iPhone của bạn.

4. **Kết nối iPhone và chọn thiết bị chạy**:
   - Cắm cáp kết nối iPhone với máy Mac (trên iPhone chọn *"Tin cậy máy tính này"* nếu được hỏi).
   - Bật chế độ nhà phát triển trên iPhone (nếu chạy iOS 16 trở lên: Vào *Cài đặt (Settings) -> Quyền riêng tư & Bảo mật (Privacy & Security) -> Chế độ nhà phát triển (Developer Mode) -> Bật và Khởi động lại máy*).
   - Tại thanh công cụ trên cùng của Xcode (cạnh nút Run ▶️), nhấp chọn thiết bị mục tiêu là **chiếc iPhone thật** của bạn.

5. **Bấm Chạy (Run / Build)**:
   - Nhấn tổ hợp phím **`Cmd + R`** hoặc bấm nút tam giác **`▶️`** ở góc trên bên trái Xcode.
   - Xcode sẽ tự động biên dịch toàn bộ mã nguồn Swift và cài đặt ứng dụng **FlipaClip 2D** trực tiếp lên màn hình chính iPhone của bạn!
   - *(Lưu ý lần đầu)*: Trên iPhone, nếu có thông báo "Nhà phát triển không đáng tin cậy", bạn chỉ cần vào *Cài đặt -> Cài đặt chung -> Quản lý VPN & Thiết bị* -> Nhấp vào Apple ID của bạn và chọn *"Tin cậy"*.
