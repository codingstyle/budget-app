import SwiftData
import SwiftUI

struct RulesSidebarView: View {
    let filterText: String
    let addToken: Int

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \LabelRule.matchText) private var rules: [LabelRule]
    @Query private var households: [Household]
    @State private var viewModel = LearningRulesViewModel()
    @State private var isAddingRule = false
    @State private var ruleBeingEdited: LabelRule?

    var body: some View {
        Group {
            if visibleRules.isEmpty {
                if rules.isEmpty {
                    ContentUnavailableView(
                        "Aucune règle",
                        systemImage: "text.badge.checkmark",
                        description: Text("Ajoutez une règle pour assigner enseigne et étiquettes.")
                    )
                    .font(.caption)
                } else {
                    ContentUnavailableView.search
                }
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: SpacingTokens.xs) {
                        ForEach(visibleRules) { rule in
                            Button {
                                presentEditor(for: rule)
                            } label: {
                                RulesSidebarRow(rule: rule)
                            }
                            .buttonStyle(.plain)
                            .help("Modifier la règle")
                            .contextMenu {
                                Button("Modifier") {
                                    presentEditor(for: rule)
                                }
                                Button("Réappliquer") {
                                    LabelRuleEngine.apply(rule, in: modelContext)
                                }
                                Button("Supprimer", role: .destructive) {
                                    viewModel.delete(rule, in: modelContext)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, SpacingTokens.xs)
                    .padding(.vertical, SpacingTokens.sm)
                }
            }
        }
        .onChange(of: addToken) { _, _ in
            presentAddRule()
        }
        .sheet(isPresented: $isAddingRule) {
            if let household = households.first {
                NavigationStack {
                    AddRuleView(household: household)
                }
            }
        }
        .sheet(item: $ruleBeingEdited) { rule in
            if let household = rule.household ?? households.first {
                NavigationStack {
                    AddRuleView(household: household, rule: rule)
                }
            }
        }
    }

    private var visibleRules: [LabelRule] {
        let needle = filterText.trimmingCharacters(in: .whitespacesAndNewlines)
        let source = needle.isEmpty ? Array(rules) : rules.filter { matches($0, needle: needle) }
        return source.sorted { $0.matchTexts.joined().localizedStandardCompare($1.matchTexts.joined()) == .orderedAscending }
    }

    private func matches(_ rule: LabelRule, needle: String) -> Bool {
        if rule.matchTexts.contains(where: { $0.localizedStandardContains(needle) }) {
            return true
        }
        if rule.enseigne?.name.localizedStandardContains(needle) == true {
            return true
        }
        return rule.tags?.contains { $0.label.localizedStandardContains(needle) } == true
    }

    private func presentAddRule() {
        guard households.first != nil else { return }
        isAddingRule = true
    }

    private func presentEditor(for rule: LabelRule) {
        ruleBeingEdited = rule
    }
}
