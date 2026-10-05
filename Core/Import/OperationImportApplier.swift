import Foundation
import SwiftData

struct OperationImportSummary: Sendable {
    var insertedCount: Int
    var skippedCount: Int
}

enum OperationImportApplier {
    @MainActor
    static func apply(
        payload: StatementPayload,
        account: BankAccount,
        context: ModelContext,
        onProgress: ((String, Double) -> Void)? = nil
    ) async throws -> OperationImportSummary {
        let existing = Set((account.operations ?? []).map(\.importFingerprint))
        var inserted = 0
        var skipped = 0
        let total = max(payload.rows.count, 1)
        onProgress?("Import des opérations…", 0)

        for (index, row) in payload.rows.enumerated() {
            let fingerprint = ImportFingerprint.make(
                accountLastFour: payload.accountLastFour,
                effectDate: row.effectDate,
                amount: row.amount,
                originalLabel: row.originalLabel
            )
            if existing.contains(fingerprint) {
                skipped += 1
            } else {
                let parsed = LabelInterpreter.parse(
                    originalLabel: row.originalLabel,
                    effectDate: row.effectDate
                )
                let operation = Operation(
                    effectDate: row.effectDate,
                    valueDate: row.valueDate ?? parsed.valueDate ?? row.effectDate,
                    originalLabel: row.originalLabel,
                    displayLabel: parsed.displayLabel,
                    merchant: parsed.merchant,
                    amount: row.amount,
                    paymentType: parsed.paymentType,
                    importFingerprint: fingerprint,
                    account: account
                )
                operation.category = row.category
                operation.subcategory = row.subcategory
                operation.pointing = row.pointing
                operation.comment = row.comment
                operation.cardLastFour = CardStore.normalizedLastFour(parsed.cardLastFour)
                operation.cardFirstFour = parsed.cardFirstFour
                operation.card = CardStore.findOrCreate(
                    lastFour: parsed.cardLastFour,
                    household: account.household,
                    in: context
                )
                operation.place = parsed.place
                operation.cardCountry = parsed.cardCountry
                operation.originalCurrencyAmount = parsed.originalCurrencyAmount
                operation.motif = parsed.motif
                operation.transferReference = parsed.reference
                operation.emetteur = parsed.emetteur
                context.insert(operation)
                inserted += 1
            }
            if shouldReport(index: index, total: payload.rows.count) {
                let fraction = 0.8 * Double(index + 1) / Double(total)
                onProgress?("Import des opérations (\(index + 1) / \(payload.rows.count))…", fraction)
                await Task.yield()
            }
        }

        if let balance = payload.balance {
            account.lastKnownBalance = balance
            account.lastKnownBalanceDate = payload.balanceDate
        }

        onProgress?("Enregistrement…", 0.85)
        await Task.yield()
        try context.save()
        onProgress?("Association des cartes…", 0.9)
        await Task.yield()
        CardStore.linkOperations(in: context)
        onProgress?("Application des règles…", 0.96)
        await Task.yield()
        LabelRuleEngine.applyAll(in: context)
        onProgress?("Import terminé", 1)
        return OperationImportSummary(insertedCount: inserted, skippedCount: skipped)
    }

    private static func shouldReport(index: Int, total: Int) -> Bool {
        index == 0 || index == total - 1 || (index + 1).isMultiple(of: 8)
    }
}
