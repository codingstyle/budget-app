import Foundation
import SwiftData

enum BudgetSchema {
    static let models: [any PersistentModel.Type] = [
        Household.self,
        BankAccount.self,
        Operation.self,
        Tag.self,
        LabelRule.self,
        Enseigne.self,
        Card.self
    ]
}
