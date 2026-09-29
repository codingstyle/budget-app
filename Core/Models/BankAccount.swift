import Foundation
import SwiftData

@Model
final class BankAccount {
    var number: String = ""
    var label: String = ""
    var bank: String = ""
    var lastKnownBalance: Decimal?
    var lastKnownBalanceDate: Date?
    var household: Household?
    @Relationship(deleteRule: .cascade, inverse: \Operation.account)
    var operations: [Operation]?

    init(
        number: String = "",
        label: String = "",
        bank: String = "",
        household: Household? = nil
    ) {
        self.number = number
        self.label = label
        self.bank = bank
        self.household = household
        self.operations = []
    }

    var lastFourDigits: String {
        String(number.filter(\.isNumber).suffix(4))
    }
}
