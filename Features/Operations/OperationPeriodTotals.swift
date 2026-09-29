import Foundation

struct OperationPeriodTotals {
    let debit: Decimal
    let credit: Decimal

    init(operations: [Operation]) {
        debit = operations.reduce(0) { $0 + ($1.debit ?? 0) }
        credit = operations.reduce(0) { $0 + ($1.credit ?? 0) }
    }
}
