import Foundation

struct StatementPayload: Sendable {
    var bank: BankBrand
    var accountLastFour: String
    var accountNumber: String = ""
    var balanceDate: Date?
    var balance: Decimal?
    var rows: [StatementOperationRow]
}
