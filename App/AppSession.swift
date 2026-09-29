import Foundation
import SwiftData

@MainActor
@Observable
final class AppSession {
    var selectedAccountID: PersistentIdentifier?
    var selectedCardID: PersistentIdentifier?
    var selectedTagID: PersistentIdentifier?
    var selectedEnseigneID: PersistentIdentifier?
    var monthYear: MonthYear = .current
    var operationSearchText = ""
    var operationsDisplayStyle: OperationsDisplayStyle = .list
    var masksAmounts = UserDefaults.standard.bool(forKey: "masksAmounts") {
        didSet {
            UserDefaults.standard.set(masksAmounts, forKey: "masksAmounts")
        }
    }
}
