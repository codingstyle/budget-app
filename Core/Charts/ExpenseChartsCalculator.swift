import Foundation
import SwiftData

enum ExpenseChartsCalculator {
    private static let unlabeledID = "untagged"
    private static let unlabeledLabel = "Sans étiquette"
    private static let unlabeledColor = "#6B7280"
    private static let unlabeledSymbol = "tag"

    @MainActor
    static func monthlyExpenses(in operations: [Operation], ending monthYear: MonthYear) -> [ExpenseMonthPoint] {
        monthYear.trailingTwelveMonths.map { month in
            let amount = operations
                .filter { month.contains($0.effectDate) && $0.isDebit }
                .reduce(Decimal.zero) { $0 + ($1.debit ?? 0) }
            return ExpenseMonthPoint(monthYear: month, amount: amount)
        }
    }

    @MainActor
    static func breakdown(in operations: [Operation], selectedTag: Tag?) -> [ExpenseBreakdownSlice] {
        var totals: [String: (slice: ExpenseBreakdownSlice, amount: Decimal)] = [:]
        for operation in operations where operation.isDebit {
            let amount = operation.debit ?? 0
            let slices = slices(for: operation, selectedTag: selectedTag)
            let share = slices.isEmpty ? amount : amount / Decimal(slices.count)
            let keys = slices.isEmpty ? [unlabeledSlice] : slices
            for slice in keys {
                let current = totals[slice.id]?.amount ?? 0
                totals[slice.id] = (slice, current + share)
            }
        }
        return totals.values
            .map { ExpenseBreakdownSlice(id: $0.slice.id, label: $0.slice.label, colorHex: $0.slice.colorHex, symbolName: $0.slice.symbolName, amount: $0.amount) }
            .filter { $0.amount > 0 }
            .sorted { $0.amount > $1.amount }
    }

    @MainActor
    private static func slices(for operation: Operation, selectedTag: Tag?) -> [ExpenseBreakdownSlice] {
        let tags = operation.tags ?? []
        if let selectedTag {
            let selectedID = selectedTag.persistentModelID
            return uniqueSlices(
                from: tags
                    .filter { $0.persistentModelID != selectedID }
                    .map(slice(from:))
            )
        }
        return uniqueSlices(from: tags.map(parentSlice(from:)))
    }

    @MainActor
    private static func parentSlice(from tag: Tag) -> ExpenseBreakdownSlice {
        let root = root(of: tag)
        return slice(from: root)
    }

    @MainActor
    private static func root(of tag: Tag) -> Tag {
        var current = tag
        while let parent = current.parent {
            current = parent
        }
        return current
    }

    @MainActor
    private static func slice(from tag: Tag) -> ExpenseBreakdownSlice {
        ExpenseBreakdownSlice(
            id: String(describing: tag.persistentModelID),
            label: tag.label,
            colorHex: tag.colorHex,
            symbolName: tag.symbolName,
            amount: 0
        )
    }

    @MainActor
    private static func uniqueSlices(from slices: [ExpenseBreakdownSlice]) -> [ExpenseBreakdownSlice] {
        var seen = Set<String>()
        return slices.filter { seen.insert($0.id).inserted }
    }

    private static var unlabeledSlice: ExpenseBreakdownSlice {
        ExpenseBreakdownSlice(
            id: unlabeledID,
            label: unlabeledLabel,
            colorHex: unlabeledColor,
            symbolName: unlabeledSymbol,
            amount: 0
        )
    }
}
