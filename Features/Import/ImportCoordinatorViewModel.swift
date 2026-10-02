import SwiftData
import SwiftUI
import UniformTypeIdentifiers

@MainActor
@Observable
final class ImportCoordinatorViewModel {
    var isImporterPresented = false
    var isProgressPresented = false
    var progressMessage = "Préparation de l’import…"
    var progressFraction = 0.0
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
        presentProgress(message: "Préparation de l’import…", fraction: 0)
        Task {
            await runImport(from: url, accounts: accounts, household: household, context: context)
        }
    }

    func createMissingAccount(
        household: Household,
        context: ModelContext
    ) {
        guard let payload = pendingPayload else { return }
        isCreatingMissingAccount = false
        pendingPayload = nil
        presentProgress(message: "Création du compte…", fraction: 0.05)
        Task {
            await Task.yield()
            let account = BankAccount(
                number: missingAccountNumber,
                label: missingAccountLabel,
                bank: missingAccountBank.rawValue,
                household: household
            )
            context.insert(account)
            do {
                let summary = try await apply(payload: payload, account: account, context: context)
                finish(summary: summary, account: account, context: context)
            } catch {
                hideProgress()
                presentError(error.localizedDescription)
            }
        }
    }

    func presentError(_ message: String) {
        errorMessage = message
        isErrorPresented = true
    }

    private func runImport(
        from url: URL,
        accounts: [BankAccount],
        household: Household?,
        context: ModelContext
    ) async {
        await Task.yield()
        let accessed = url.startAccessingSecurityScopedResource()
        defer {
            if accessed {
                url.stopAccessingSecurityScopedResource()
            }
        }

        do {
            updateProgress(message: "Lecture du fichier…", fraction: 0.08)
            await Task.yield()
            let data = try Data(contentsOf: url)
            updateProgress(message: "Analyse du relevé…", fraction: 0.18)
            await Task.yield()
            let payload = try BNPParibasImporter.parse(data: data)
            guard let household else {
                throw AppError.householdMissing
            }
            if let account = accounts.first(where: { $0.matchesLastFour(payload.accountLastFour) }) {
                let summary = try await apply(payload: payload, account: account, context: context)
                finish(summary: summary, account: account, context: context)
            } else {
                pendingPayload = payload
                pendingLastFour = payload.accountLastFour
                missingAccountNumber = payload.accountLastFour
                missingAccountLabel = "Compte \(payload.accountLastFour)"
                hideProgress()
                await Task.yield()
                isCreatingMissingAccount = true
            }
        } catch {
            hideProgress()
            presentError(error.localizedDescription)
        }
    }

    private func apply(
        payload: BNPFilePayload,
        account: BankAccount,
        context: ModelContext
    ) async throws -> OperationImportSummary {
        let summary = try await OperationImportApplier.apply(
            payload: payload,
            account: account,
            context: context
        ) { [weak self] message, fraction in
            self?.updateProgress(message: message, fraction: 0.25 + (0.65 * fraction))
        }
        updateProgress(message: "Recherche des remboursements…", fraction: 0.95)
        await Task.yield()
        return summary
    }

    private func finish(summary: OperationImportSummary, account: BankAccount, context: ModelContext) {
        statusMessage = "\(summary.insertedCount) opération(s) importée(s), \(summary.skippedCount) ignorée(s)."
        let all = (try? context.fetch(FetchDescriptor<Operation>())) ?? []
        let accountOperations = all.filter { $0.account?.persistentModelID == account.persistentModelID }
        pendingRefundSuggestions = RefundMatcher.suggestions(in: accountOperations)
        refundReviewOperations = accountOperations
        hideProgress()
        isReviewingRefunds = pendingRefundSuggestions.isEmpty == false
    }

    private func presentProgress(message: String, fraction: Double) {
        progressMessage = message
        progressFraction = fraction
        isProgressPresented = true
    }

    private func updateProgress(message: String, fraction: Double) {
        progressMessage = message
        progressFraction = min(max(fraction, 0), 1)
    }

    private func hideProgress() {
        isProgressPresented = false
        progressMessage = "Préparation de l’import…"
        progressFraction = 0
    }
}
