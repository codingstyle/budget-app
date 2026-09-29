import AppKit
import SwiftUI

struct ColorHex {
    static func color(from hex: String) -> Color {
        var sanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if sanitized.hasPrefix("#") {
            sanitized.removeFirst()
        }
        guard sanitized.count == 6, let value = UInt32(sanitized, radix: 16) else {
            return ColorTokens.accent
        }
        let red = Double((value >> 16) & 0xFF) / 255
        let green = Double((value >> 8) & 0xFF) / 255
        let blue = Double(value & 0xFF) / 255
        return Color(red: red, green: green, blue: blue)
    }

    static func rgb(from hex: String) -> (red: Double, green: Double, blue: Double) {
        var sanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if sanitized.hasPrefix("#") {
            sanitized.removeFirst()
        }
        guard sanitized.count == 6, let value = UInt32(sanitized, radix: 16) else {
            return (0.36, 0.55, 0.94)
        }
        return (
            Double((value >> 16) & 0xFF) / 255,
            Double((value >> 8) & 0xFF) / 255,
            Double(value & 0xFF) / 255
        )
    }

    static func contrastingForeground(from hex: String) -> Color {
        let rgb = rgb(from: hex)
        let luminance = 0.2126 * sRGBLinear(rgb.red)
            + 0.7152 * sRGBLinear(rgb.green)
            + 0.0722 * sRGBLinear(rgb.blue)
        return luminance > 0.45 ? Color(white: 0.12) : Color.white
    }

    private static func sRGBLinear(_ component: Double) -> Double {
        if component <= 0.04045 {
            return component / 12.92
        }
        return pow((component + 0.055) / 1.055, 2.4)
    }

    static func hex(from color: Color) -> String {
        let converted = NSColor(color)
        guard let rgb = converted.usingColorSpace(.sRGB) else { return "#5B8DEF" }
        return String(
            format: "#%02X%02X%02X",
            Int(round(rgb.redComponent * 255)),
            Int(round(rgb.greenComponent * 255)),
            Int(round(rgb.blueComponent * 255))
        )
    }
}
