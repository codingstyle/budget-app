import Foundation

struct ParsedLabel: Sendable, Equatable {
    var paymentType: PaymentType
    var merchant: String
    var displayLabel: String
    var valueDate: Date?
    var place: String
    var cardLastFour: String
    var cardFirstFour: String
    var cardCountry: String
    var originalCurrencyAmount: String
    var motif: String
    var reference: String
    var emetteur: String
    var normalizedKey: String
    var matchedRule: Bool
}
