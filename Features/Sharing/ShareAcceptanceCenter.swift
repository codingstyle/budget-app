import CloudKit
import Foundation

extension Notification.Name {
    static let cloudKitShareAccepted = Notification.Name("Budget.cloudKitShareAccepted")
}

@MainActor
@Observable
final class ShareAcceptanceCenter {
    static let shared = ShareAcceptanceCenter()

    var pendingMetadata: [CKShare.Metadata] = []
    var errorMessage: String?
    var isErrorPresented = false

    func enqueue(_ metadata: CKShare.Metadata) {
        pendingMetadata.append(metadata)
        NotificationCenter.default.post(name: .cloudKitShareAccepted, object: nil)
    }
}
