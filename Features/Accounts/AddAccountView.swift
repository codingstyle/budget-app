import SwiftData
import SwiftUI

struct AddAccountView: View {
    var isOnboarding: Bool = false
    var onCreated: ((BankAccount) -> Void)?

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = AddAccountViewModel()

    var body: some View {
        Form {
            Section("Compte bancaire") {
                TextField("Numéro", text: $viewModel.number)
                TextField("Libellé", text: $viewModel.label)
                BankBrandPicker(selection: $viewModel.bank)
            }

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundStyle(ColorTokens.debit)
            }

            Button("Enregistrer", action: save)
                .disabled(viewModel.canSave == false)
                .keyboardShortcut(.defaultAction)
        }
        .formStyle(.grouped)
        .padding(SpacingTokens.xl)
        .frame(minWidth: 420, minHeight: isOnboarding ? 360 : 280)
        .navigationTitle(isOnboarding ? "Ajouter un compte" : "Nouveau compte")
    }

    private func save() {
        guard let account = viewModel.save(in: modelContext) else { return }
        onCreated?(account)
        if isOnboarding == false {
            dismiss()
        }
    }
}

#Preview {
    AddAccountView(isOnboarding: true)
        .modelContainer(BudgetModelContainer.make())
}
