import SwiftUI

struct MissingAccountSheet: View {
    @Bindable var viewModel: ImportCoordinatorViewModel
    let onCancel: () -> Void
    let onCreate: () -> Void

    var body: some View {
        Form {
            Text("Aucun compte ne correspond aux chiffres \(viewModel.pendingLastFour). Créez-le pour poursuivre l’import.")
            TextField("Numéro", text: $viewModel.missingAccountNumber)
            TextField("Libellé", text: $viewModel.missingAccountLabel)
            BankBrandPicker(selection: $viewModel.missingAccountBank)
        }
        .formStyle(.grouped)
        .padding(SpacingTokens.lg)
        .frame(minWidth: 400, minHeight: 240)
        .navigationTitle("Compte introuvable")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Annuler", action: onCancel)
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Créer et importer", action: onCreate)
            }
        }
    }
}
