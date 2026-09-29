import SwiftData
import SwiftUI

struct AddCardView: View {
    var onSaved: ((Card) -> Void)?

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: AddCardViewModel

    init(card: Card? = nil, onSaved: ((Card) -> Void)? = nil) {
        self.onSaved = onSaved
        _viewModel = State(initialValue: AddCardViewModel(card: card))
    }

    var body: some View {
        Form {
            Section("Carte") {
                TextField("Titulaire", text: $viewModel.cardholderName)
                TextField("4 derniers chiffres", text: $viewModel.lastFour)
                CardTypePicker(selection: $viewModel.type)
            }

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundStyle(ColorTokens.debit)
            }
        }
        .formStyle(.grouped)
        .padding(SpacingTokens.xl)
        .frame(minWidth: 420, minHeight: 280)
        .navigationTitle(viewModel.isEditing ? "Modifier la carte" : "Nouvelle carte")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Annuler", action: dismiss.callAsFunction)
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Enregistrer", action: save)
                    .disabled(viewModel.canSave == false)
                    .keyboardShortcut(.defaultAction)
            }
        }
    }

    private func save() {
        guard let card = viewModel.save(in: modelContext) else { return }
        onSaved?(card)
        dismiss()
    }
}

#Preview {
    AddCardView()
        .modelContainer(BudgetModelContainer.make())
}
