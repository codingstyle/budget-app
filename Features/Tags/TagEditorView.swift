import SwiftData
import SwiftUI

struct TagEditorView: View {
    let tag: Tag?
    let household: Household
    let availableTags: [Tag]
    let onSaved: ((Tag) -> Void)?

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: TagEditorViewModel

    init(
        tag: Tag?,
        household: Household,
        parent: Tag? = nil,
        availableTags: [Tag],
        onSaved: ((Tag) -> Void)? = nil
    ) {
        self.tag = tag
        self.household = household
        self.availableTags = availableTags
        self.onSaved = onSaved
        _viewModel = State(initialValue: TagEditorViewModel(tag: tag, parent: parent))
    }

    var body: some View {
        Form {
            TextField("Libellé", text: $viewModel.label)
            Picker("Tag parent", selection: $viewModel.parentID) {
                Text("Aucun").tag(Optional<PersistentIdentifier>.none)
                ForEach(parentCandidates) { candidate in
                    Text(candidate.label).tag(Optional(candidate.persistentModelID))
                }
            }
            DSColorPalettePicker(hex: $viewModel.colorHex)
            DSSymbolPicker(symbolName: $viewModel.symbolName)
            previewChip
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundStyle(ColorTokens.debit)
            }
        }
        .formStyle(.grouped)
        .padding(SpacingTokens.lg)
        .frame(minWidth: 380, minHeight: 380)
        .navigationTitle(tag == nil ? "Nouvelle étiquette" : "Étiquette")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Annuler", action: dismiss.callAsFunction)
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Enregistrer", action: save)
            }
        }
    }

    private var previewChip: some View {
        DSTagChip(
            title: viewModel.label.isEmpty ? "Aperçu" : viewModel.label,
            symbolName: viewModel.symbolName,
            colorHex: viewModel.colorHex
        )
        .padding(.vertical, SpacingTokens.sm)
    }

    private var parentCandidates: [Tag] {
        availableTags.filter { candidate in
            guard candidate.persistentModelID != tag?.persistentModelID else { return false }
            if let tag {
                return tag.descendantIDs.contains(candidate.persistentModelID) == false
            }
            return true
        }
        .sorted { $0.label.localizedStandardCompare($1.label) == .orderedAscending }
    }

    private func save() {
        let parent = availableTags.first { $0.persistentModelID == viewModel.parentID }
        guard let saved = viewModel.save(tag: tag, household: household, parent: parent, in: modelContext) else {
            return
        }
        onSaved?(saved)
        dismiss()
    }
}
