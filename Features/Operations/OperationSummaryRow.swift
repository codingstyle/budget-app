import SwiftData
import SwiftUI

struct OperationSummaryRow: View {
    let operation: Operation

    var body: some View {
        HStack(alignment: .center, spacing: SpacingTokens.md) {
            VStack(alignment: .leading, spacing: 2) {
                OperationDateCell(date: operation.effectDate)
                HStack(spacing: SpacingTokens.sm) {
                    DSEnseigneLogo(imageData: operation.enseigne?.logoData, size: 16)
                    Text(operation.enseigne?.name ?? operation.merchant)
                        .textCase(.uppercase)
                        .lineLimit(1)
                }
                Text(operation.displayLabel.isEmpty ? operation.originalLabel : operation.displayLabel)
                    .font(.caption)
                    .foregroundStyle(ColorTokens.secondaryText)
                    .lineLimit(2)
            }
            Spacer(minLength: SpacingTokens.sm)
            DSMoneyText(amount: operation.debit ?? operation.credit, isCredit: operation.isCredit)
                .frame(width: 90)
        }
        .accessibilityElement(children: .combine)
    }
}
