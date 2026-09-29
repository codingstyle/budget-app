import SwiftUI

private struct AccountDebugHandlerKey: FocusedValueKey {
    typealias Value = AccountDebugHandler
}

extension FocusedValues {
    var accountDebugHandler: AccountDebugHandler? {
        get { self[AccountDebugHandlerKey.self] }
        set { self[AccountDebugHandlerKey.self] = newValue }
    }
}
