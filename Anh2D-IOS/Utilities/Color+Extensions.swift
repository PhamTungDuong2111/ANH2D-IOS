import SwiftUI
import UIKit

public extension Color {
    // FlipaClip Brand Coral & Accents (matching ADR design system)
    static let flipaCoral = Color(hex: "#FF5353")
    static let flipaOrange = Color(hex: "#FF5353") // Alias for backward compatibility
    static let flipaDarkBg = Color(hex: "#121418")
    static let flipaSurface = Color(hex: "#1B1E24")
    static let flipaPanelDark = Color(hex: "#1B1E24")
    static let flipaPanelElevated = Color(hex: "#242933")
    static let flipaHover = Color(hex: "#2F3542")
    static let flipaGreen = Color(hex: "#34C759")
    static let flipaNeonGreen = Color(hex: "#34C759")
    static let flipaBlue = Color(hex: "#0084FF")
    static let flipaCyan = Color(hex: "#00E5FF")
    static let flipaYellow = Color(hex: "#FFCC00")
    static let flipaRed = Color(hex: "#FF3B30")
    static let flipaBorder = Color.white.opacity(0.08)

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

public extension UIColor {
    static let flipaCoral = UIColor(hex: "#FF5353")!
    static let flipaDarkBg = UIColor(hex: "#121418")!
    static let flipaSurface = UIColor(hex: "#1B1E24")!
    static let flipaPanelElevated = UIColor(hex: "#242933")!
    static let flipaHover = UIColor(hex: "#2F3542")!
    static let flipaGreen = UIColor(hex: "#34C759")!

    convenience init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        guard Scanner(string: hex).scanHexInt64(&int) else { return nil }
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }

        self.init(
            red: CGFloat(r) / 255.0,
            green: CGFloat(g) / 255.0,
            blue: CGFloat(b) / 255.0,
            alpha: CGFloat(a) / 255.0
        )
    }

    func toHex() -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb: Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format: "#%06x", rgb).uppercased()
    }
}
