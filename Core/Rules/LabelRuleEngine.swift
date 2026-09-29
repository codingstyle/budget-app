import Foundation
import SwiftData

enum LabelRuleEngine {
    @MainActor
    static func matches(_ rule: LabelRule, operation: Operation) -> Bool {
        let needles = rule.matchTexts
        guard needles.isEmpty == false else { return false }
        return needles.contains { needle in
            operation.originalLabel.localizedStandardContains(needle)
                || operation.displayLabel.localizedStandardContains(needle)
        }
    }

    @MainActor
    static func apply(_ rule: LabelRule, to operation: Operation) -> Bool {
        guard matches(rule, operation: operation) else { return false }
        var didChange = false

        if let enseigne = rule.enseigne {
            if operation.enseigne == nil {
                operation.enseigne = enseigne
                if operation.merchant.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    operation.merchant = enseigne.name
                }
                didChange = true
            }
        }

        var assigned = operation.tags ?? []
        for tag in rule.tags ?? [] {
            let alreadyAssigned = assigned.contains { $0.persistentModelID == tag.persistentModelID }
            guard alreadyAssigned == false else { continue }
            assigned.append(tag)
            didChange = true
        }
        if didChange {
            operation.tags = assigned
        }
        return didChange
    }

    @MainActor
    static func apply(_ rule: LabelRule, in context: ModelContext) {
        let operations = (try? context.fetch(FetchDescriptor<Operation>())) ?? []
        var didChange = false
        for operation in operations {
            if apply(rule, to: operation) {
                didChange = true
            }
        }
        if didChange {
            try? context.save()
        }
    }

    @MainActor
    static func applyAll(in context: ModelContext) {
        let rules = (try? context.fetch(FetchDescriptor<LabelRule>())) ?? []
        let operations = (try? context.fetch(FetchDescriptor<Operation>())) ?? []
        var didChange = false
        for operation in operations {
            for rule in rules {
                if apply(rule, to: operation) {
                    didChange = true
                }
            }
        }
        if didChange {
            try? context.save()
        }
    }
}
