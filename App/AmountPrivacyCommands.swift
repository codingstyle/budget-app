import SwiftUI

struct AmountPrivacyCommands: Commands {
    @Bindable var session: AppSession

    var body: some Commands {
        CommandMenu("Présentation") {
            Toggle("Masquer les montants", isOn: $session.masksAmounts)
                .keyboardShortcut("m", modifiers: [.command, .shift])
        }
    }
}
