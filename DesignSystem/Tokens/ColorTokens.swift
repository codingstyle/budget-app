import AppKit
import SwiftUI

enum ColorTokens {
    static let background = Color(nsColor: .windowBackgroundColor)
    static let sidebar = Color(nsColor: NSColor(name: nil, dynamicProvider: { appearance in
        let isDark = appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
        return isDark
            ? NSColor(calibratedWhite: 0.18, alpha: 1)
            : NSColor(calibratedWhite: 0.90, alpha: 1)
    }))
    static let credit = Color(red: 0.16, green: 0.55, blue: 0.35)
    static let debit = Color(red: 0.75, green: 0.22, blue: 0.22)
    static let secondaryText = Color.secondary
    static let accent = Color.accentColor
}
