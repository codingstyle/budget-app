import SwiftUI

private struct MasksAmountsKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    var masksAmounts: Bool {
        get { self[MasksAmountsKey.self] }
        set { self[MasksAmountsKey.self] = newValue }
    }
}
