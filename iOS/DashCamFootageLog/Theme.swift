import SwiftUI

/// Unique palette for Dash Cam Footage Log.
enum ClipEntryTheme {
    static let accent = Color(hex: "#B23A48")
    static let background = Color(hex: "#210E12")
    static let card = Color(hex: "#210E12").opacity(0.55)
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.65)

    static var titleFont: Font { .system(.title2, design: .rounded).weight(.bold) }
    static var bodyFont: Font { .system(.body, design: .rounded) }
    static var captionFont: Font { .system(.caption, design: .rounded) }
}

extension Color {
    init(hex: String) {
        let s = hex.trimmingCharacters(in: .init(charactersIn: "#"))
        var v: UInt64 = 0
        Scanner(string: s).scanHexInt64(&v)
        let r = Double((v >> 16) & 0xFF) / 255
        let g = Double((v >> 8) & 0xFF) / 255
        let b = Double(v & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
