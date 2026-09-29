import SwiftUI

struct DSMoneyText: View {
    let amount: Decimal?
    var isCredit: Bool = false
    @Environment(\.masksAmounts) private var masksAmounts

    var body: some View {
        Text(EuroFormat.displayString(from: amount, masked: masksAmounts))
            .monospacedDigit()
            .foregroundStyle(amount == nil ? Color.clear : (isCredit ? ColorTokens.credit : ColorTokens.debit))
            .frame(maxWidth: .infinity, alignment: .trailing)
            .accessibilityValue(accessibilityValue)
    }

    private var accessibilityValue: String {
        if masksAmounts, amount != nil {
            return "Masqué"
        }
        return EuroFormat.string(from: amount)
    }
}

#Preview {
    DSMoneyText(amount: 12.5, isCredit: true)
        .padding()
}
