import SwiftUI

struct DSTagChip: View {
    let title: String
    let symbolName: String
    let colorHex: String
    var isSelected: Bool = false
    var isCompact: Bool = false

    var body: some View {
        let foreground = ColorHex.contrastingForeground(from: colorHex)
        HStack(spacing: isCompact ? SpacingTokens.xs : SpacingTokens.sm) {
            Image(systemName: symbolName)
            Text(title)
        }
        .font(isCompact ? .caption : .callout)
        .foregroundStyle(foreground)
        .padding(.horizontal, isCompact ? SpacingTokens.sm : SpacingTokens.md)
        .padding(.vertical, isCompact ? 2 : SpacingTokens.sm)
        .background(ColorHex.color(from: colorHex), in: Capsule())
        .overlay {
            Capsule()
                .strokeBorder(isSelected ? foreground : Color.clear, lineWidth: 2)
        }
        .shadow(color: isSelected ? Color.black.opacity(0.18) : Color.clear, radius: 2, y: 1)
        .accessibilityLabel(title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 8) {
        DSTagChip(title: "Alimentation", symbolName: "cart", colorHex: "#5B8DEF", isSelected: true)
        DSTagChip(title: "Santé", symbolName: "heart", colorHex: "#F4E4C1")
        DSTagChip(title: "Toutes", symbolName: "tray.full", colorHex: "#6B7280")
        DSTagChip(title: "Courses", symbolName: "cart", colorHex: "#5B8DEF", isCompact: true)
    }
    .padding()
}
