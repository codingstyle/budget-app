import Foundation

struct ExpenseBreakdownSlice: Identifiable, Hashable {
    let id: String
    let label: String
    let colorHex: String
    let symbolName: String
    let amount: Decimal
}
