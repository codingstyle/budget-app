import Foundation

struct BNPOperationRow: Sendable {
    var effectDate: Date
    var originalLabel: String
    var amount: Decimal
    var category: String
    var subcategory: String
    var pointing: String
    var comment: String
}

struct BNPFilePayload: Sendable {
    var accountLastFour: String
    var balanceDate: Date?
    var balance: Decimal?
    var rows: [BNPOperationRow]
}
