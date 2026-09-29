import Foundation
import SwiftData

@Model
final class Card {
    var typeRaw: String = CardType.visaClassic.rawValue
    var cardholderName: String = ""
    var lastFour: String = ""
    var household: Household?
    @Relationship(deleteRule: .nullify, inverse: \Operation.card)
    var operations: [Operation]?

    init(
        type: CardType = .visaClassic,
        cardholderName: String = "",
        lastFour: String = "",
        household: Household? = nil
    ) {
        self.typeRaw = type.rawValue
        self.cardholderName = cardholderName
        self.lastFour = String(lastFour.filter(\.isNumber).suffix(4))
        self.household = household
        self.operations = []
    }

    var type: CardType {
        get { CardType(rawValue: typeRaw) ?? .visaClassic }
        set { typeRaw = newValue.rawValue }
    }

    var maskedNumber: String {
        "XXXX XXXX XXXX \(lastFour)"
    }
}
