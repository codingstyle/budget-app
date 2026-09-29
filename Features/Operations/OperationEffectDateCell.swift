import SwiftData
import SwiftUI

struct OperationEffectDateCell: View {
    let operation: Operation

    var body: some View {
        HStack(spacing: SpacingTokens.xs) {
            if operation.isLinkedRefund {
                Image(systemName: "arrow.turn.down.right")
                    .foregroundStyle(ColorTokens.secondaryText)
                    .accessibilityLabel("Remboursement lié")
            }
            OperationLabelHint(originalLabel: operation.originalLabel)
            OperationDateCell(date: operation.effectDate)
        }
    }
}
