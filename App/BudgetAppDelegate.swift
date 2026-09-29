import AppKit
import CloudKit

final class BudgetAppDelegate: NSObject, NSApplicationDelegate {
    func application(_ application: NSApplication, userDidAcceptCloudKitShareWith metadata: CKShare.Metadata) {
        Task { @MainActor in
            ShareAcceptanceCenter.shared.enqueue(metadata)
        }
    }
}
