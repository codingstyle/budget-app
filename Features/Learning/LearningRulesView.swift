import SwiftData
import SwiftUI

struct LearningRulesView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \LabelRule.matchText) private var rules: [LabelRule]
    @Query private var households: [Household]
    @State private var viewModel = LearningRulesViewModel()
    @State private var isAddingRule = false

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Règles")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Fermer", action: dismiss.callAsFunction)
                    }
                    ToolbarItemGroup(placement: .primaryAction) {
                        Button("Réappliquer", action: reapplyAll)
                            .disabled(rules.isEmpty)
                        Button("Ajouter", systemImage: "plus", action: presentAddRule)
                            .disabled(households.first == nil)
                    }
                }
                .sheet(isPresented: $isAddingRule) {
                    if let household = households.first {
                        NavigationStack {
                            AddRuleView(household: household)
                        }
                    }
                }
        }
        .frame(minWidth: 820, minHeight: 620)
    }

    @ViewBuilder
    private var content: some View {
        if rules.isEmpty {
            emptyState
        } else {
            List {
                ForEach(rules) { rule in
                    LearningRuleRow(rule: rule)
                }
                .onDelete(perform: delete)
            }
        }
    }

    @ViewBuilder
    private var emptyState: some View {
        if households.first == nil {
            DSEmptyState(
                title: "Aucune règle",
                message: "Créez une règle pour détecter un texte dans le libellé, puis assigner une enseigne et des étiquettes.",
                systemImage: "text.badge.checkmark"
            )
        } else {
            DSEmptyState(
                title: "Aucune règle",
                message: "Créez une règle pour détecter un texte dans le libellé, puis assigner une enseigne et des étiquettes.",
                systemImage: "text.badge.checkmark",
                actionTitle: "Ajouter une règle",
                action: presentAddRule
            )
        }
    }

    private func presentAddRule() {
        isAddingRule = true
    }

    private func reapplyAll() {
        viewModel.reapplyAll(in: modelContext)
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            viewModel.delete(rules[index], in: modelContext)
        }
    }
}
