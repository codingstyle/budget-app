import Foundation
import SwiftData

@MainActor
@Observable
final class AddAccountViewModel {
    var number = ""
    var label = ""
    var bank: BankBrand = .bnpParibas
    var errorMessage: String?

    var canSave: Bool {
        number.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
            && label.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
    }

    func save(in context: ModelContext) -> BankAccount? {
        errorMessage = nil
        guard canSave else {
            errorMessage = "Renseignez le numéro, le libellé et la banque."
            return nil
        }

        let household = HouseholdBootstrap.loadOrCreate(in: context)
        let account = BankAccount(
            number: number.trimmingCharacters(in: .whitespacesAndNewlines),
            label: label.trimmingCharacters(in: .whitespacesAndNewlines),
            bank: bank.rawValue,
            household: household
        )
        context.insert(account)
        do {
            try context.save()
            return account
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }
}
