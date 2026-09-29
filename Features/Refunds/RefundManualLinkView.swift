import SwiftData
import SwiftUI

struct RefundManualLinkView: View {
    let operations: [Operation]

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: RefundManualLinkViewModel

    init(credit: Operation, operations: [Operation]) {
        self.operations = operations
        _viewModel = State(initialValue: RefundManualLinkViewModel(credit: credit))
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: SpacingTokens.lg) {
                labeledBlock("Crédit") {
                    OperationSummaryRow(operation: viewModel.credit)
                }

                TextField("Rechercher un débit", text: $viewModel.searchText)
                    .textFieldStyle(.roundedBorder)

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(ColorTokens.debit)
                }

                if candidates.isEmpty {
                    Text("Aucun débit antérieur disponible.")
                        .foregroundStyle(ColorTokens.secondaryText)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(candidates) { debit in
                        Button {
                            link(debit)
                        } label: {
                            OperationSummaryRow(operation: debit)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(SpacingTokens.lg)
            .navigationTitle("Associer un remboursement")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler", action: dismiss.callAsFunction)
                }
            }
        }
        .frame(minWidth: 560, minHeight: 480)
    }

    private var candidates: [Operation] {
        viewModel.candidates(from: operations)
    }

    private func labeledBlock(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: SpacingTokens.sm) {
            Text(title)
                .font(.headline)
            content()
                .padding(SpacingTokens.md)
                .background(ColorTokens.sidebar, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
    }

    private func link(_ debit: Operation) {
        guard viewModel.link(debit, in: modelContext) else { return }
        dismiss()
    }
}
