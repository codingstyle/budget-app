import SwiftUI

struct ExpenseChartsView: View {
    let historyOperations: [Operation]
    let monthOperations: [Operation]
    let monthYear: MonthYear
    let selectedTag: Tag?

    var body: some View {
        if monthlyPoints.allSatisfy({ $0.amount == 0 }) && slices.isEmpty {
            DSEmptyState(
                title: "Aucune dépense",
                message: "Aucune dépense n’est disponible pour les 12 derniers mois avec les filtres actuels.",
                systemImage: "chart.bar.xaxis"
            )
        } else {
            ScrollView {
                VStack(alignment: .leading, spacing: SpacingTokens.xl) {
                    VStack(alignment: .leading, spacing: SpacingTokens.md) {
                        Text("Évolution des dépenses")
                            .font(.headline)
                        Text("12 mois jusqu’à \(monthYear.title)")
                            .font(.caption)
                            .foregroundStyle(ColorTokens.secondaryText)
                        ExpenseHistogramChart(points: monthlyPoints)
                            .frame(minHeight: 240)
                    }
                    VStack(alignment: .leading, spacing: SpacingTokens.md) {
                        Text("Répartition du mois")
                            .font(.headline)
                        Text(breakdownSubtitle)
                            .font(.caption)
                            .foregroundStyle(ColorTokens.secondaryText)
                        if slices.isEmpty {
                            Text("Aucune dépense à répartir pour ce mois.")
                                .foregroundStyle(ColorTokens.secondaryText)
                        } else {
                            HStack(alignment: .center, spacing: SpacingTokens.xl) {
                                ExpenseBreakdownChart(slices: slices)
                                    .frame(minWidth: 220, minHeight: 220)
                                ExpenseBreakdownLegend(slices: slices)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                }
            }
        }
    }

    private var monthlyPoints: [ExpenseMonthPoint] {
        ExpenseChartsCalculator.monthlyExpenses(in: historyOperations, ending: monthYear)
    }

    private var slices: [ExpenseBreakdownSlice] {
        ExpenseChartsCalculator.breakdown(in: monthOperations, selectedTag: selectedTag)
    }

    private var breakdownSubtitle: String {
        if let selectedTag {
            return "Par autres étiquettes des dépenses « \(selectedTag.label) » — \(monthYear.title)"
        }
        return "Par étiquette parente — \(monthYear.title)"
    }
}
