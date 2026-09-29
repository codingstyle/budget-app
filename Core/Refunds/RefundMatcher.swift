import Foundation
import SwiftData

enum RefundMatcher {
    @MainActor
    static func suggestions(in operations: [Operation]) -> [RefundSuggestion] {
        let unmatchedCredits = operations
            .filter { $0.isCredit && $0.refundOf == nil }
            .sorted { $0.effectDate > $1.effectDate }
        let unmatchedDebits = operations.filter { $0.isDebit && $0.refund == nil }
        var usedDebitIDs = Set<PersistentIdentifier>()
        var result: [RefundSuggestion] = []

        for credit in unmatchedCredits {
            guard let debit = bestDebit(for: credit, among: unmatchedDebits, excluding: usedDebitIDs) else {
                continue
            }
            usedDebitIDs.insert(debit.persistentModelID)
            result.append(
                RefundSuggestion(creditID: credit.persistentModelID, debitID: debit.persistentModelID)
            )
        }
        return result
    }

    @MainActor
    static func groupedForDisplay(_ operations: [Operation]) -> [Operation] {
        var attached = Set<PersistentIdentifier>()
        var result: [Operation] = []

        for operation in operations {
            if attached.contains(operation.persistentModelID) {
                continue
            }
            if let debit = operation.refundOf {
                result.append(debit)
                result.append(operation)
                attached.insert(debit.persistentModelID)
                attached.insert(operation.persistentModelID)
                continue
            }
            if operation.refund != nil {
                continue
            }
            result.append(operation)
        }
        return result
    }

    @MainActor
    private static func bestDebit(
        for credit: Operation,
        among debits: [Operation],
        excluding usedDebitIDs: Set<PersistentIdentifier>
    ) -> Operation? {
        let candidates = debits.filter { debit in
            guard usedDebitIDs.contains(debit.persistentModelID) == false else { return false }
            guard debit.account?.persistentModelID == credit.account?.persistentModelID else { return false }
            guard debit.effectDate < credit.effectDate else { return false }
            guard debit.amount == -credit.amount else { return false }
            return enseignesCompatible(credit, debit)
        }
        return candidates.max { lhs, rhs in
            let leftScore = enseigneScore(credit, lhs)
            let rightScore = enseigneScore(credit, rhs)
            if leftScore != rightScore {
                return leftScore < rightScore
            }
            return lhs.effectDate < rhs.effectDate
        }
    }

    @MainActor
    private static func enseignesCompatible(_ credit: Operation, _ debit: Operation) -> Bool {
        guard let creditEnseigne = credit.enseigne, let debitEnseigne = debit.enseigne else {
            return true
        }
        return creditEnseigne.persistentModelID == debitEnseigne.persistentModelID
    }

    @MainActor
    private static func enseigneScore(_ credit: Operation, _ debit: Operation) -> Int {
        guard let creditEnseigne = credit.enseigne, let debitEnseigne = debit.enseigne else {
            return 0
        }
        return creditEnseigne.persistentModelID == debitEnseigne.persistentModelID ? 1 : 0
    }
}
