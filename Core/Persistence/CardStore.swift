import Foundation
import SwiftData

enum CardStore {
    @MainActor
    static func matching(lastFour: String, in household: Household?, context: ModelContext? = nil) -> Card? {
        let digits = normalizedLastFour(lastFour)
        guard digits.count == 4 else { return nil }

        if let household {
            if let match = (household.cards ?? []).first(where: { $0.lastFour == digits }) {
                return match
            }
        }

        guard let context else { return nil }
        let cards = (try? context.fetch(FetchDescriptor<Card>())) ?? []
        return cards.first { card in
            guard card.lastFour == digits else { return false }
            guard let household else { return true }
            return card.household?.persistentModelID == household.persistentModelID
        }
    }

    @MainActor
    static func findOrCreate(lastFour: String, household: Household?, in context: ModelContext) -> Card? {
        let digits = normalizedLastFour(lastFour)
        guard digits.count == 4 else { return nil }
        if let existing = matching(lastFour: digits, in: household, context: context) {
            return existing
        }

        let owner = household ?? HouseholdBootstrap.loadOrCreate(in: context)
        let card = Card(
            type: .visaClassic,
            cardholderName: "Carte \(digits)",
            lastFour: digits,
            household: owner
        )
        context.insert(card)
        return card
    }

    @MainActor
    static func attach(_ card: Card, in context: ModelContext) {
        linkOperations(in: context)
    }

    @MainActor
    static func linkOperations(in context: ModelContext) {
        let operations = (try? context.fetch(FetchDescriptor<Operation>())) ?? []
        var didChange = false
        for operation in operations {
            if applyCardMapping(to: operation, in: context) {
                didChange = true
            }
        }
        if didChange {
            try? context.save()
        }
    }

    @MainActor
    static func applyCardMapping(to operation: Operation, in context: ModelContext) -> Bool {
        var didChange = false
        var lastFour = normalizedLastFour(operation.cardLastFour)
        if lastFour.count != 4 {
            let parsed = LabelInterpreter.parse(
                originalLabel: operation.originalLabel,
                effectDate: operation.effectDate
            )
            lastFour = normalizedLastFour(parsed.cardLastFour)
            if lastFour.count == 4 {
                operation.cardLastFour = lastFour
                if operation.cardFirstFour.isEmpty {
                    operation.cardFirstFour = parsed.cardFirstFour
                }
                didChange = true
            }
        }

        guard lastFour.count == 4 else { return didChange }

        let household = operation.account?.household ?? operation.card?.household
        guard let card = findOrCreate(lastFour: lastFour, household: household, in: context) else {
            return didChange
        }
        guard operation.card?.persistentModelID != card.persistentModelID else {
            return didChange
        }
        operation.card = card
        return true
    }

    static func normalizedLastFour(_ raw: String) -> String {
        String(raw.filter(\.isNumber).suffix(4))
    }
}
