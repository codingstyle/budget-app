import Charts
import SwiftUI

struct ExpenseBreakdownChart: View {
    let slices: [ExpenseBreakdownSlice]
    @State private var selectedAmount: Double?

    var body: some View {
        Chart(slices) { slice in
            SectorMark(
                angle: .value("Montant", slice.amount.chartValue),
                innerRadius: .ratio(0.55),
                angularInset: 1.5
            )
            .foregroundStyle(ColorHex.color(from: slice.colorHex))
            .opacity(isHighlighted(slice) ? 1 : 0.45)
        }
        .chartAngleSelection(value: $selectedAmount)
        .chartBackground { _ in
            if let selectedSlice {
                ExpenseBreakdownTooltip(slice: selectedSlice)
            }
        }
        .chartLegend(.hidden)
        .accessibilityLabel("Répartition des dépenses du mois")
    }

    private var selectedSlice: ExpenseBreakdownSlice? {
        guard let selectedAmount else { return nil }
        var start = 0.0
        for slice in slices {
            let end = start + slice.amount.chartValue
            if selectedAmount > start, selectedAmount <= end {
                return slice
            }
            start = end
        }
        return nil
    }

    private func isHighlighted(_ slice: ExpenseBreakdownSlice) -> Bool {
        guard let selectedSlice else { return true }
        return selectedSlice.id == slice.id
    }
}
