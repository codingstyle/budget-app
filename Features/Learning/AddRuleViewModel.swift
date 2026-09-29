import Foundation
import SwiftData

@MainActor
@Observable
final class AddRuleViewModel {
    var matchEntries: [MatchTextEntry]
    var selectedEnseigneID: PersistentIdentifier?
    var selectedTagIDs: Set<PersistentIdentifier> = []
    var errorMessage: String?

    private let rule: LabelRule?

    var isEditing: Bool { rule != nil }

    init(rule: LabelRule? = nil, matchText: String = "") {
        self.rule = rule
        if let rule {
            let texts = rule.matchTexts
            self.matchEntries = texts.isEmpty ? [MatchTextEntry()] : texts.map { MatchTextEntry(text: $0) }
            self.selectedEnseigneID = rule.enseigne?.persistentModelID
            self.selectedTagIDs = Set((rule.tags ?? []).map(\.persistentModelID))
        } else {
            let initial = matchText.trimmingCharacters(in: .whitespacesAndNewlines)
            self.matchEntries = [MatchTextEntry(text: initial)]
        }
    }

    var canSave: Bool {
        cleanedMatchTexts.isEmpty == false
            && (selectedEnseigneID != nil || selectedTagIDs.isEmpty == false)
    }

    func addMatchText() {
        matchEntries.append(MatchTextEntry())
    }

    func removeMatchText(id: UUID) {
        guard matchEntries.count > 1 else { return }
        matchEntries.removeAll { $0.id == id }
    }

    func toggleTag(_ tag: Tag) {
        let id = tag.persistentModelID
        if selectedTagIDs.contains(id) {
            selectedTagIDs.remove(id)
        } else {
            selectedTagIDs.insert(id)
        }
    }

    func selectEnseigne(_ enseigne: Enseigne) {
        selectedEnseigneID = enseigne.persistentModelID
    }

    func save(household: Household, enseignes: [Enseigne], tags: [Tag], in context: ModelContext) -> LabelRule? {
        errorMessage = nil
        let needles = cleanedMatchTexts
        guard needles.isEmpty == false else {
            errorMessage = "Indiquez au moins un texte à détecter dans le libellé."
            return nil
        }
        guard selectedEnseigneID != nil || selectedTagIDs.isEmpty == false else {
            errorMessage = "Ajoutez au moins une action : enseigne ou étiquette."
            return nil
        }

        let target: LabelRule
        if let rule {
            target = rule
        } else {
            target = LabelRule(household: household)
            context.insert(target)
        }
        target.matchTexts = needles
        target.enseigne = enseignes.first { $0.persistentModelID == selectedEnseigneID }
        target.tags = tags.filter { selectedTagIDs.contains($0.persistentModelID) }
        do {
            try context.save()
            LabelRuleEngine.apply(target, in: context)
            return target
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }

    private var cleanedMatchTexts: [String] {
        matchEntries
            .map { $0.text.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.isEmpty == false }
    }
}
