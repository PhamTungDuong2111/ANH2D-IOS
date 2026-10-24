import SwiftUI

public enum ToolType: String, CaseIterable, Identifiable {
    case pen = "Pen"
    case pencil = "Pencil"
    case brush = "Brush"
    case highlighter = "Highlighter"
    case eraser = "Eraser"
    case bucket = "Bucket"
    case lasso = "Lasso"
    case ruler = "Ruler"
    case text = "Text"
    case shapes = "Shapes"
    case eyedropper = "Eyedropper"
    case smudge = "Smudge"
    case blur = "Blur"

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .pen: return "Bút mực (Pen)"
        case .pencil: return "Bút chì (Pencil)"
        case .brush: return "Cọ vẽ (Brush)"
        case .highlighter: return "Dạ quang (Highlighter)"
        case .eraser: return "Cục tẩy (Eraser)"
        case .bucket: return "Đổ màu (Fill Bucket)"
        case .lasso: return "Chọn vùng (Lasso)"
        case .ruler: return "Thước kẻ (Ruler)"
        case .text: return "Văn bản (Text)"
        case .shapes: return "Hình khối (Shapes)"
        case .eyedropper: return "Hút màu (Eyedropper)"
        case .smudge: return "Làm mịn (Smudge)"
        case .blur: return "Làm mờ (Blur)"
        }
    }

    public var iconName: String {
        switch self {
        case .pen: return "pencil.tip"
        case .pencil: return "pencil"
        case .brush: return "paintbrush.pointed.fill"
        case .highlighter: return "highlighter"
        case .eraser: return "eraser.fill"
        case .bucket: return "drop.fill"
        case .lasso: return "lasso"
        case .ruler: return "ruler.fill"
        case .text: return "textformat"
        case .shapes: return "square.on.circle"
        case .eyedropper: return "eyedropper.halffull"
        case .smudge: return "hand.draw.fill"
        case .blur: return "camera.filters"
        }
    }
}

public enum ShapeType: String, CaseIterable, Identifiable {
    case line = "Line"
    case rectangle = "Rectangle"
    case circle = "Circle"
    case star = "Star"

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .line: return "Đường thẳng"
        case .rectangle: return "Hình chữ nhật"
        case .circle: return "Hình tròn / Ellipse"
        case .star: return "Ngôi sao 5 cánh"
        }
    }

    public var iconName: String {
        switch self {
        case .line: return "line.diagonal"
        case .rectangle: return "rectangle"
        case .circle: return "circle"
        case .star: return "star.fill"
        }
    }
}

public enum RulerType: String, CaseIterable, Identifiable {
    case none = "None"
    case straight = "Straight"
    case circle = "Circle"
    case square = "Square"

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .none: return "Tắt thước"
        case .straight: return "Thước thẳng"
        case .circle: return "Thước tròn"
        case .square: return "Thước vuông"
        }
    }

    public var iconName: String {
        switch self {
        case .none: return "xmark.circle"
        case .straight: return "ruler"
        case .circle: return "circle.dashed"
        case .square: return "square.dashed"
        }
    }
}

public enum BlendMode: String, CaseIterable, Identifiable {
    case normal = "Normal"
    case multiply = "Multiply"
    case screen = "Screen"
    case overlay = "Overlay"
    case darken = "Darken"
    case lighten = "Lighten"
    case add = "Add / Plus"
    case colorDodge = "Color Dodge"

    public var id: String { rawValue }

    public var title: String { rawValue }

    public func toCGBlendMode() -> CGBlendMode {
        switch self {
        case .normal: return .normal
        case .multiply: return .multiply
        case .screen: return .screen
        case .overlay: return .overlay
        case .darken: return .darken
        case .lighten: return .lighten
        case .add: return .plusLighter
        case .colorDodge: return .colorDodge
        }
    }
}

public enum CanvasPreset: String, CaseIterable, Identifiable {
    case youtube16_9 = "YouTube 720p (16:9)"
    case youtube1080p = "YouTube 1080p (16:9)"
    case tiktok9_16 = "TikTok / Reels (9:16)"
    case instagram1_1 = "Instagram Post (1:1)"
    case classic4_3 = "Classic Standard (4:3)"

    public var id: String { rawValue }

    public var dimensions: (width: Int, height: Int) {
        switch self {
        case .youtube16_9: return (1280, 720)
        case .youtube1080p: return (1920, 1080)
        case .tiktok9_16: return (1080, 1920)
        case .instagram1_1: return (1080, 1080)
        case .classic4_3: return (1440, 1080)
        }
    }
}

public enum AppLayout: String, CaseIterable, Identifiable {
    case classic = "Classic"
    case studio = "Studio"

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .classic: return "Chế độ Classic (Vẽ toàn màn hình)"
        case .studio: return "Chế độ Studio (Đa tầng Timeline & Audio)"
        }
    }
}

public struct WeeklyChallenge: Identifiable {
    public let id = UUID()
    public let title: String
    public let prompt: String
    public let prize: String
    public let daysRemaining: Int
    public let tag: String
}
