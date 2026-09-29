import SwiftData
import SwiftUI

struct AddQuickTagView: View {
    let household: Household
    var onCreated: (Tag) -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = TagEditorViewModel()
    @FocusState private var isNameFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: SpacingTokens.sm) {
            TextField("Nom de l’étiquette", text: $viewModel.label)
                .textFieldStyle(.roundedBorder)
                .focused($isNameFocused)
                .onSubmit(save)
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(ColorTokens.debit)
            }
        }
        .padding(SpacingTokens.lg)
        .frame(minWidth: 320)
        .onAppear { isNameFocused = true }
    }

    private func save() {
        guard let tag = viewModel.save(tag: nil, household: household, parent: nil, in: modelContext) else {
            return
        }
        onCreated(tag)
        dismiss()
    }
}
