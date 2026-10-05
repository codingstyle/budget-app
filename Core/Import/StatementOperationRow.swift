import Foundation

struct StatementOperationRow: Sendable {
    var effectDate: Date
    var valueDate: Date?
    var originalLabel: String
    var amount: Decimal
    var category: String = ""
    var subcategory: String = ""
    var pointing: String = ""
    var comment: String = ""
}
