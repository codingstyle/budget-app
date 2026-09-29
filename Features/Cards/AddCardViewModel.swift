import Foundation
import SwiftData

@MainActor
@Observable
final class AddCardViewModel {
    var cardholderName = ""
    var lastFour = ""
    var type: CardType = .visaPremier
    var errorMessage: String?

    private let card: Card?

    var isEditing: Bool { card != nil }

    init(card: Card? = nil) {
        self.card = card
        if let card {
            cardholderName = card.cardholderName
            lastFour = card.lastFour
            type = card.type
        }
    }

    var canSave: Bool {
        cardholderName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
            && String(lastFour.filter(\.isNumber)).count == 4
    }

    func save(in context: ModelContext) -> Card? {
        errorMessage = nil
        guard canSave else {
            errorMessage = "Renseignez le titulaire et les 4 derniers chiffres."
            return nil
        }

        let household = card?.household ?? HouseholdBootstrap.loadOrCreate(in: context)
        let digits = String(lastFour.filter(\.isNumber).suffix(4))
        let duplicate = CardStore.matching(lastFour: digits, in: household, context: context)
        if let duplicate, duplicate.persistentModelID != card?.persistentModelID {
            errorMessage = "Une carte avec ces 4 chiffres existe déjà."
            return nil
        }

        let target: Card
        if let card {
            target = card
        } else {
            target = Card(household: household)
            context.insert(target)
        }
        target.type = type
        target.cardholderName = cardholderName.trimmingCharacters(in: .whitespacesAndNewlines)
        if target.lastFour != digits {
            target.lastFour = digits
            for operation in target.operations ?? [] {
                operation.cardLastFour = digits
            }
        }

        do {
            try context.save()
            CardStore.attach(target, in: context)
            return target
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }
}
