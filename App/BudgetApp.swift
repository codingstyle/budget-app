import SwiftData
import SwiftUI

@main
struct BudgetApp: App {
    @NSApplicationDelegateAdaptor(BudgetAppDelegate.self) private var appDelegate
    @State private var session = AppSession()
    private let container = BudgetModelContainer.make()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(session)
                .environment(\.masksAmounts, session.masksAmounts)
                .environment(\.appTheme, AppTheme())
                .environment(\.locale, AppLocale.locale)
                .environment(\.calendar, AppLocale.calendar)
        }
        .modelContainer(container)
        .defaultSize(width: 1100, height: 720)
        .commands {
            CommandGroup(replacing: .newItem) {}
            AmountPrivacyCommands(session: session)
            DebugCommands()
        }
    }
}
