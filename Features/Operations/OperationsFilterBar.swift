import SwiftUI

struct OperationsFilterBar: View {
    @Binding var monthYear: MonthYear
    @Binding var displayStyle: OperationsDisplayStyle
    let balance: Decimal?
    let totals: OperationPeriodTotals
    @Environment(\.masksAmounts) private var masksAmounts

    var body: some View {
        HStack(alignment: .center) {
            MonthYearFilterView(monthYear: $monthYear)
            OperationsDisplayStylePicker(selection: $displayStyle)
            Spacer()
            VStack(alignment: .trailing, spacing: SpacingTokens.xs) {
                if let balance {
                    Text(EuroFormat.displayString(from: balance, masked: masksAmounts))
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                        .monospacedDigit()
                        .accessibilityLabel("Solde")
                        .accessibilityValue(accessibilityValue(for: balance))
                }
                HStack(spacing: SpacingTokens.lg) {
                    sumText(totals.debit, isCredit: false, label: "Débits")
                    sumText(totals.credit, isCredit: true, label: "Crédits")
                }
            }
        }
    }

    private func sumText(_ amount: Decimal, isCredit: Bool, label: String) -> some View {
        Text(EuroFormat.displayString(from: amount, masked: masksAmounts))
            .font(.title3)
            .fontWeight(.medium)
            .monospacedDigit()
            .foregroundStyle(isCredit ? ColorTokens.credit : ColorTokens.debit)
            .accessibilityLabel(label)
            .accessibilityValue(accessibilityValue(for: amount))
    }

    private func accessibilityValue(for amount: Decimal?) -> String {
        if masksAmounts, amount != nil {
            return "Masqué"
        }
        return EuroFormat.string(from: amount)
    }
}
