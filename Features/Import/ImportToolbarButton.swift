import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct ImportToolbarButton: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var households: [Household]
    @Query(sort: \BankAccount.label) private var accounts: [BankAccount]
    @Bindable var viewModel: ImportCoordinatorViewModel

    var body: some View {
        Button("Importer Excel", systemImage: "square.and.arrow.down", action: viewModel.presentImporter)
            .fileImporter(
                isPresented: $viewModel.isImporterPresented,
                allowedContentTypes: spreadsheetTypes,
                allowsMultipleSelection: false,
                onCompletion: handleImportResult
            )
            .sheet(isPresented: $viewModel.isCreatingMissingAccount) {
                if let household = households.first {
                    MissingAccountSheet(
                        viewModel: viewModel,
                        onCancel: cancelMissingAccount,
                        onCreate: {
                            viewModel.createMissingAccount(household: household, context: modelContext)
                        }
                    )
                }
            }
            .sheet(isPresented: $viewModel.isReviewingRefunds) {
                RefundReviewView(
                    suggestions: viewModel.pendingRefundSuggestions,
                    operations: viewModel.refundReviewOperations
                )
            }
            .alert(
                "Import",
                isPresented: $viewModel.isErrorPresented
            ) {
                Button("OK", role: .cancel) {
                    viewModel.errorMessage = nil
                    viewModel.isErrorPresented = false
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
    }

    private var spreadsheetTypes: [UTType] {
        var types: [UTType] = [.spreadsheet]
        if let xlsx = UTType(filenameExtension: "xlsx") {
            types.append(xlsx)
        }
        if let xls = UTType(filenameExtension: "xls") {
            types.append(xls)
        }
        return types
    }

    private func handleImportResult(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first, let household = households.first else { return }
            viewModel.importFile(at: url, accounts: accounts, household: household, context: modelContext)
        case .failure(let error):
            viewModel.presentError(error.localizedDescription)
        }
    }

    private func cancelMissingAccount() {
        viewModel.isCreatingMissingAccount = false
        viewModel.pendingPayload = nil
    }
}
