import Foundation
import SwiftData

struct OperationImportSummary: Sendable {
    var insertedCount: Int
    var skippedCount: Int
}

enum OperationImportApplier {
    @MainActor
    static func apply(
        payload: BNPFilePayload,
        account: BankAccount,
        context: ModelContext
    ) throws -> OperationImportSummary {
        let existing = Set((account.operations ?? []).map(\.importFingerprint))
        var inserted = 0
        var skipped = 0

        for row in payload.rows {
            let fingerprint = ImportFingerprint.make(
                accountLastFour: payload.accountLastFour,
                effectDate: row.effectDate,
                amount: row.amount,
                originalLabel: row.originalLabel
            )
            if existing.contains(fingerprint) {
                skipped += 1
                continue
            }

            let parsed = LabelInterpreter.parse(
                originalLabel: row.originalLabel,
                effectDate: row.effectDate
            )
            let operation = Operation(
                effectDate: row.effectDate,
                valueDate: parsed.valueDate ?? row.effectDate,
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

        if let balance = payload.balance {
            account.lastKnownBalance = balance
            account.lastKnownBalanceDate = payload.balanceDate
        }

        try context.save()
        CardStore.linkOperations(in: context)
        LabelRuleEngine.applyAll(in: context)
        return OperationImportSummary(insertedCount: inserted, skippedCount: skipped)
    }
}
