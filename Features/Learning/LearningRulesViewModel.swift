import SwiftData
import SwiftUI

@MainActor
@Observable
final class LearningRulesViewModel {
    func delete(_ rule: LabelRule, in context: ModelContext) {
        context.delete(rule)
        try? context.save()
    }

    func reapplyAll(in context: ModelContext) {
        LabelRuleEngine.applyAll(in: context)
    }
}
