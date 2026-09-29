import Foundation
import SwiftData

enum HouseholdBootstrap {
    @MainActor
    static func existing(in context: ModelContext) -> Household? {
        let descriptor = FetchDescriptor<Household>(sortBy: [SortDescriptor(\.name)])
        return try? context.fetch(descriptor).first
    }

    @MainActor
    static func loadOrCreate(in context: ModelContext) -> Household {
        if let existing = existing(in: context) {
            return existing
        }
        let household = Household(name: "Foyer")
        context.insert(household)
        try? context.save()
        return household
    }
}
