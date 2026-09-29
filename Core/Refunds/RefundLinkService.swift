import Foundation
import SwiftData

enum RefundLinkService {
    @MainActor
    static func link(credit: Operation, to debit: Operation, in context: ModelContext) throws {
        guard credit.isCredit, debit.isDebit else { return }
        guard credit.effectDate > debit.effectDate else { return }
        guard credit.refundOf == nil, debit.refund == nil else { return }
        credit.refundOf = debit
        try context.save()
    }

    @MainActor
    static func unlink(credit: Operation, in context: ModelContext) throws {
        credit.refundOf = nil
        try context.save()
    }
}
