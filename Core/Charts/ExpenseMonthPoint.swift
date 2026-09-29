import Foundation

struct ExpenseMonthPoint: Identifiable, Hashable {
    let monthYear: MonthYear
    let amount: Decimal

    var id: String { "\(monthYear.year)-\(monthYear.month)" }
    var date: Date { monthYear.startDate }
}
