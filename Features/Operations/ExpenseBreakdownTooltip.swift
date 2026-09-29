import SwiftUI

struct ExpenseBreakdownTooltip: View {
    let slice: ExpenseBreakdownSlice

    var body: some View {
        HStack(spacing: SpacingTokens.sm) {
            DSTagGlyph(symbolName: slice.symbolName, colorHex: slice.colorHex)
            Text(slice.label)
                .lineLimit(1)
        }
        .padding(.horizontal, SpacingTokens.md)
        .padding(.vertical, SpacingTokens.sm)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
        .accessibilityHidden(true)
    }
}
