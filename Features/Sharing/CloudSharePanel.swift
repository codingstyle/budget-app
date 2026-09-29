import AppKit
import CloudKit
import Foundation

@MainActor
enum CloudSharePanel {
    static func present(share: CKShare, container: CKContainer) {
        let provider = NSItemProvider()
        provider.registerCKShare(share, container: container, allowedSharingOptions: .standard)
        let picker = NSSharingServicePicker(items: [provider])
        guard let window = NSApp.keyWindow ?? NSApp.windows.first,
              let contentView = window.contentView else { return }
        let rect = NSRect(x: contentView.bounds.midX, y: contentView.bounds.midY, width: 1, height: 1)
        picker.show(relativeTo: rect, of: contentView, preferredEdge: .minY)
    }
}
