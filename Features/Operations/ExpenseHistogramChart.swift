import Charts
import SwiftUI

struct ExpenseHistogramChart: View {
    let points: [ExpenseMonthPoint]
    @Environment(\.masksAmounts) private var masksAmounts

    var body: some View {
        Chart(points) { point in
            BarMark(
                x: .value("Mois", point.date, unit: .month),
                y: .value("Dépenses", point.amount.chartValue)
            )
            .foregroundStyle(ColorTokens.debit)
            .cornerRadius(3)
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .month)) { _ in
                AxisGridLine()
                AxisTick()
                AxisValueLabel(format: .dateTime.month(.abbreviated).locale(AppLocale.locale))
            }
        }
        .chartYAxis {
            AxisMarks { value in
                AxisGridLine()
                AxisValueLabel {
                    if let amount = value.as(Double.self) {
                        Text(EuroFormat.displayString(from: Decimal(amount), masked: masksAmounts))
                    }
                }
            }
        }
        .chartYAxisLabel("Dépenses")
        .accessibilityLabel("Histogramme des dépenses sur 12 mois")
    }
}
