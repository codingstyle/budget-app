import Foundation
import SwiftData

enum EnseigneStore {
    @MainActor
    static func findOrCreate(named name: String, household: Household, in context: ModelContext) -> Enseigne? {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else { return nil }
        let key = LabelNormalizer.normalize(trimmed)

        if let existing = existing(matching: key, household: household, in: context) {
            return existing
        }

        let enseigne = Enseigne(name: trimmed, household: household)
        context.insert(enseigne)
        return enseigne
    }

    @MainActor
    private static func existing(
        matching key: String,
        household: Household,
        in context: ModelContext
    ) -> Enseigne? {
        if let match = (household.enseignes ?? []).first(where: { $0.normalizedName == key }) {
            return match
        }
        let enseignes = (try? context.fetch(FetchDescriptor<Enseigne>())) ?? []
        return enseignes.first {
            $0.normalizedName == key && $0.household?.persistentModelID == household.persistentModelID
        }
    }
}
