import SwiftData
import SwiftUI
import UniformTypeIdentifiers

@MainActor
@Observable
final class ImportCoordinatorViewModel {
    var isImporterPresented = false
    var isCreatingMissingAccount = false
    var errorMessage: String?
    var statusMessage: String?
    var pendingPayload: BNPFilePayload?
    var pendingLastFour = ""
    var missingAccountNumber = ""
    var missingAccountLabel = ""
    var missingAccountBank: BankBrand = .bnpParibas
    var isErrorPresented = false
    var isReviewingRefunds = false
    var pendingRefundSuggestions: [RefundSuggestion] = []
    var refundReviewOperations: [Operation] = []

    func presentImporter() {
        errorMessage = nil
        isImporterPresented = true
    }

    func importFile(
        at url: URL,
        accounts: [BankAccount],
        household: Household?,
        context: ModelContext
    ) {
        errorMessage = nil
        isErrorPresented = false
        let accessed = url.startAccessingSecurityScopedResource()
        defer {
            if accessed {
                url.stopAccessingSecurityScopedResource()
            }
        }

        do {
            let payload = try BNPParibasImporter.load(from: url)
            guard let household else {
                throw AppError.householdMissing
            }
            if let account = accounts.first(where: { $0.matchesLastFour(payload.accountLastFour) }) {
                let summary = try OperationImportApplier.apply(
                    payload: payload,
                    account: account,
                    context: context
                )
                finish(summary: summary, account: account, context: context)
            } else {
                pendingPayload = payload
                pendingLastFour = payload.accountLastFour
                missingAccountNumber = payload.accountLastFour
                missingAccountLabel = "Compte \(payload.accountLastFour)"
                isCreatingMissingAccount = true
            }
        } catch {
            presentError(error.localizedDescription)
        }
    }

    func createMissingAccount(
        household: Household,
        context: ModelContext
    ) {
        guard let payload = pendingPayload else { return }
        let account = BankAccount(
            number: missingAccountNumber,
            label: missingAccountLabel,
            bank: missingAccountBank.rawValue,
            household: household
        )
        context.insert(account)
        do {
            let summary = try OperationImportApplier.apply(
                payload: payload,
                account: account,
                context: context
            )
            isCreatingMissingAccount = false
            pendingPayload = nil
            finish(summary: summary, account: account, context: context)
        } catch {
            presentError(error.localizedDescription)
        }
    }

    func presentError(_ message: String) {
        errorMessage = message
        isErrorPresented = true
    }

    private func finish(summary: OperationImportSummary, account: BankAccount, context: ModelContext) {
        statusMessage = "\(summary.insertedCount) opération(s) importée(s), \(summary.skippedCount) ignorée(s)."
        let all = (try? context.fetch(FetchDescriptor<Operation>())) ?? []
        let accountOperations = all.filter { $0.account?.persistentModelID == account.persistentModelID }
        pendingRefundSuggestions = RefundMatcher.suggestions(in: accountOperations)
        refundReviewOperations = accountOperations
        isReviewingRefunds = pendingRefundSuggestions.isEmpty == false
    }
}
