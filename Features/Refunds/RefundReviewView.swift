import SwiftData
import SwiftUI

struct RefundReviewView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: RefundReviewViewModel

    init(suggestions: [RefundSuggestion], operations: [Operation]) {
        _viewModel = State(initialValue: RefundReviewViewModel(suggestions: suggestions, operations: operations))
    }

    var body: some View {
        NavigationStack {
            Group {
                if let pair = viewModel.current {
                    VStack(alignment: .leading, spacing: SpacingTokens.lg) {
                        Text("Un crédit semble rembourser ce débit (même montant, date postérieure).")
                            .foregroundStyle(ColorTokens.secondaryText)
                        labeledBlock("Débit") {
                            OperationSummaryRow(operation: pair.debit)
                        }
                        labeledBlock("Crédit") {
                            OperationSummaryRow(operation: pair.credit)
                        }
                        Spacer()
                    }
                    .padding(SpacingTokens.lg)
                } else {
                    ContentUnavailableView(
                        "Aucune proposition",
                        systemImage: "checkmark.circle",
                        description: Text("Tous les rapprochements ont été traités.")
                    )
                }
            }
            .navigationTitle("Remboursement proposé")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Ignorer", action: skip)
                        .disabled(viewModel.hasCurrent == false)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Associer", action: confirm)
                        .disabled(viewModel.hasCurrent == false)
                }
            }
        }
        .frame(minWidth: 520, minHeight: 360)
        .onChange(of: viewModel.hasCurrent) { _, hasCurrent in
            if hasCurrent == false {
                dismiss()
            }
        }
        .onAppear {
            if viewModel.hasCurrent == false {
                dismiss()
            }
        }
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

    private func confirm() {
        viewModel.confirm(in: modelContext)
    }

    private func skip() {
        viewModel.skip()
        if viewModel.hasCurrent == false {
            dismiss()
        }
    }
}
