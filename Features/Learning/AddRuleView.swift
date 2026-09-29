import SwiftData
import SwiftUI

struct AddRuleView: View {
    let household: Household

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Enseigne.name) private var enseignes: [Enseigne]
    @Query(sort: \Tag.label) private var tags: [Tag]
    @State private var viewModel: AddRuleViewModel
    @State private var isCreatingEnseigne = false
    @State private var isCreatingTag = false

    init(household: Household, rule: LabelRule? = nil, matchText: String = "") {
        self.household = household
        _viewModel = State(initialValue: AddRuleViewModel(rule: rule, matchText: matchText))
    }

    var body: some View {
        @Bindable var viewModel = viewModel
        Form {
            Section("Condition") {
                Text("Le libellé contient l’un de ces textes")
                    .foregroundStyle(ColorTokens.secondaryText)
                ForEach($viewModel.matchEntries) { $entry in
                    HStack {
                        TextField("Texte à détecter", text: $entry.text)
                        if viewModel.matchEntries.count > 1 {
                            Button("Supprimer", systemImage: "minus.circle") {
                                viewModel.removeMatchText(id: entry.id)
                            }
                            .labelStyle(.iconOnly)
                            .buttonStyle(.borderless)
                            .foregroundStyle(ColorTokens.debit)
                        }
                    }
                }
                Button("Ajouter un texte", systemImage: "plus", action: viewModel.addMatchText)
            }

            Section("Actions") {
                Picker("Enseigne", selection: $viewModel.selectedEnseigneID) {
                    Text("Aucune").tag(Optional<PersistentIdentifier>.none)
                    ForEach(enseignes) { enseigne in
                        Text(enseigne.name).tag(Optional(enseigne.persistentModelID))
                    }
                }
                Button("Nouvelle enseigne…", action: presentEnseigneCreator)

                Text("Étiquettes")
                    .font(.headline)
                if tags.isEmpty {
                    Text("Aucune étiquette. Créez-en une pour cette règle.")
                        .foregroundStyle(.secondary)
                } else {
                    RuleTagTreePicker(
                        tags: Array(tags),
                        selectedIDs: viewModel.selectedTagIDs,
                        onToggle: viewModel.toggleTag
                    )
                }
                Button("Nouvelle étiquette…", action: presentTagCreator)
            }

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundStyle(ColorTokens.debit)
            }
        }
        .formStyle(.grouped)
        .padding(SpacingTokens.lg)
        .frame(minWidth: 460, minHeight: 520)
        .navigationTitle(viewModel.isEditing ? "Modifier la règle" : "Nouvelle règle")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Annuler", action: dismiss.callAsFunction)
            }
            ToolbarItem(placement: .confirmationAction) {
                Button(viewModel.isEditing ? "Enregistrer et appliquer" : "Créer et appliquer", action: save)
                    .disabled(viewModel.canSave == false)
            }
        }
        .sheet(isPresented: $isCreatingEnseigne) {
            AddEnseigneView(household: household) { enseigne in
                viewModel.selectEnseigne(enseigne)
            }
        }
        .sheet(isPresented: $isCreatingTag) {
            AddQuickTagView(household: household, onCreated: viewModel.toggleTag)
        }
    }

    private func presentEnseigneCreator() {
        isCreatingEnseigne = true
    }

    private func presentTagCreator() {
        isCreatingTag = true
    }

    private func save() {
        guard viewModel.save(household: household, enseignes: enseignes, tags: tags, in: modelContext) != nil else {
            return
        }
        dismiss()
    }
}
