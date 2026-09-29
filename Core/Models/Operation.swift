import Foundation
import SwiftData

@Model
final class Operation {
    var effectDate: Date = Date.now
    var valueDate: Date = Date.now
    var place: String = ""
    var originalLabel: String = ""
    var displayLabel: String = ""
    var merchant: String = ""
    var amount: Decimal = 0
    var paymentTypeRaw: String = PaymentType.unknown.rawValue
    var importFingerprint: String = ""
    var category: String = ""
    var subcategory: String = ""
    var pointing: String = ""
    var comment: String = ""
    var cardLastFour: String = ""
    var cardFirstFour: String = ""
    var cardCountry: String = ""
    var originalCurrencyAmount: String = ""
    var motif: String = ""
    var transferReference: String = ""
    var emetteur: String = ""
    var account: BankAccount?
    var card: Card?
    var enseigne: Enseigne?
    @Relationship(deleteRule: .nullify, inverse: \Tag.operations)
    var tags: [Tag]?
    var refundOf: Operation?
    @Relationship(deleteRule: .nullify, inverse: \Operation.refundOf)
    var refund: Operation?

    init(
        effectDate: Date = .now,
        valueDate: Date = .now,
        originalLabel: String = "",
        displayLabel: String = "",
        merchant: String = "",
        amount: Decimal = 0,
        paymentType: PaymentType = .unknown,
        importFingerprint: String = "",
        account: BankAccount? = nil
    ) {
        self.effectDate = effectDate
        self.valueDate = valueDate
        self.originalLabel = originalLabel
        self.displayLabel = displayLabel
        self.merchant = merchant
        self.amount = amount
        self.paymentTypeRaw = paymentType.rawValue
        self.importFingerprint = importFingerprint
        self.account = account
        self.card = nil
        self.enseigne = nil
        self.tags = []
        self.refundOf = nil
        self.refund = nil
    }

    var isCredit: Bool { amount > 0 }
    var isDebit: Bool { amount < 0 }
    var isLinkedRefund: Bool { refundOf != nil }

    var paymentType: PaymentType {
        get { PaymentType(rawValue: paymentTypeRaw) ?? .unknown }
        set { paymentTypeRaw = newValue.rawValue }
    }

    var debit: Decimal? {
        amount < 0 ? -amount : nil
    }

    var credit: Decimal? {
        amount > 0 ? amount : nil
    }
}
