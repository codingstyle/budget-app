import Foundation
import SwiftData

@MainActor
@Observable
final class RefundReviewViewModel {
    private(set) var remaining: [RefundSuggestion]
    private let operations: [Operation]

    init(suggestions: [RefundSuggestion], operations: [Operation]) {
        self.remaining = suggestions
        self.operations = operations
        dropInvalid()
    }

    var current: (credit: Operation, debit: Operation)? {
        guard let suggestion = remaining.first else { return nil }
        guard let credit = operation(suggestion.creditID), let debit = operation(suggestion.debitID) else {
            return nil
        }
        return (credit, debit)
    }

    var hasCurrent: Bool { current != nil }

    func confirm(in context: ModelContext) {
        guard let pair = current else { return }
        try? RefundLinkService.link(credit: pair.credit, to: pair.debit, in: context)
        remaining.removeFirst()
        dropInvalid()
    }

    func skip() {
        if remaining.isEmpty == false {
            remaining.removeFirst()
        }
        dropInvalid()
    }

    private func dropInvalid() {
        remaining.removeAll { suggestion in
            guard let credit = operation(suggestion.creditID), let debit = operation(suggestion.debitID) else {
                return true
            }
            return credit.refundOf != nil || debit.refund != nil
        }
    }

    private func operation(_ id: PersistentIdentifier) -> Operation? {
        operations.first { $0.persistentModelID == id }
    }
}
