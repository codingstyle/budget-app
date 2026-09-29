import SwiftUI

struct ExpenseBreakdownLegend: View {
    let slices: [ExpenseBreakdownSlice]
    @Environment(\.masksAmounts) private var masksAmounts

    var body: some View {
        VStack(alignment: .leading, spacing: SpacingTokens.sm) {
            ForEach(slices) { slice in
                HStack(spacing: SpacingTokens.sm) {
                    DSTagGlyph(symbolName: slice.symbolName, colorHex: slice.colorHex)
                    Text(slice.label)
                        .lineLimit(1)
                    Spacer(minLength: SpacingTokens.sm)
                    Text(EuroFormat.displayString(from: slice.amount, masked: masksAmounts))
                        .monospacedDigit()
                        .foregroundStyle(ColorTokens.debit)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(slice.label) \(accessibilityValue(for: slice.amount))")
            }
        }
    }

    private func accessibilityValue(for amount: Decimal) -> String {
        if masksAmounts {
            return "Masqué"
        }
        return EuroFormat.string(from: amount)
    }
}
