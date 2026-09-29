import Foundation
import SwiftData

@Model
final class Household {
    var name: String = "Foyer"
    @Relationship(deleteRule: .cascade, inverse: \BankAccount.household)
    var accounts: [BankAccount]?
    @Relationship(deleteRule: .cascade, inverse: \Tag.household)
    var tags: [Tag]?
    @Relationship(deleteRule: .cascade, inverse: \LabelRule.household)
    var rules: [LabelRule]?
    @Relationship(deleteRule: .cascade, inverse: \Enseigne.household)
    var enseignes: [Enseigne]?
    @Relationship(deleteRule: .cascade, inverse: \Card.household)
    var cards: [Card]?

    init(name: String = "Foyer") {
        self.name = name
        self.accounts = []
        self.tags = []
        self.rules = []
        self.enseignes = []
        self.cards = []
    }
}
