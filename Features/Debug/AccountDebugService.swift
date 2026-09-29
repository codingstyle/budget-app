import Foundation
import SwiftData

enum AccountDebugService {
    @MainActor
    static func clearOperations(of account: BankAccount, in context: ModelContext) throws {
        for operation in account.operations ?? [] {
            context.delete(operation)
        }
        account.operations = []
        account.lastKnownBalance = 0
        account.lastKnownBalanceDate = nil
        try context.save()
    }

    @MainActor
    static func clearTags(of account: BankAccount, in context: ModelContext) throws {
        let household = account.household
        for tag in household?.tags ?? [] {
            context.delete(tag)
        }
        household?.tags = []
        for operation in account.operations ?? [] {
            operation.tags = []
        }
        try context.save()
    }

    @MainActor
    static func clearEnseignes(of account: BankAccount, in context: ModelContext) throws {
        let household = account.household
        for enseigne in household?.enseignes ?? [] {
            context.delete(enseigne)
        }
        household?.enseignes = []
        for householdAccount in household?.accounts ?? [account] {
            for operation in householdAccount.operations ?? [] {
                operation.enseigne = nil
            }
        }
        try context.save()
    }
}
