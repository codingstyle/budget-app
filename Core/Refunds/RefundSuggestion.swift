import Foundation
import SwiftData

struct RefundSuggestion: Identifiable, Hashable {
    let creditID: PersistentIdentifier
    let debitID: PersistentIdentifier

    var id: PersistentIdentifier { creditID }
}
