import Foundation
import SwiftData

@MainActor
@Observable
final class RefundManualLinkViewModel {
    let credit: Operation
    var searchText = ""
    var errorMessage: String?

    init(credit: Operation) {
        self.credit = credit
    }

    func candidates(from operations: [Operation]) -> [Operation] {
        let needle = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        return operations.filter { debit in
            guard debit.isDebit else { return false }
            guard debit.refund == nil else { return false }
            guard debit.account?.persistentModelID == credit.account?.persistentModelID else { return false }
            guard debit.effectDate < credit.effectDate else { return false }
            guard matchesSearch(debit, needle: needle) else { return false }
            return true
        }
        .sorted { $0.effectDate > $1.effectDate }
    }

    func link(_ debit: Operation, in context: ModelContext) -> Bool {
        errorMessage = nil
        do {
            try RefundLinkService.link(credit: credit, to: debit, in: context)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    private func matchesSearch(_ debit: Operation, needle: String) -> Bool {
        guard needle.isEmpty == false else { return true }
        if debit.matchesSearch(needle) {
            return true
        }
        let amount = EuroFormat.string(from: debit.debit)
        return amount.localizedStandardContains(needle)
    }
}
