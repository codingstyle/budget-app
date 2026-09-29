import Foundation

extension BankAccount {
    func matchesLastFour(_ lastFour: String) -> Bool {
        lastFourDigits == lastFour
    }
}
