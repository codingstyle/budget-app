import SwiftData
import SwiftUI

struct ShareAcceptanceObserver: ViewModifier {
    @Environment(\.modelContext) private var modelContext

    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: .cloudKitShareAccepted)) { _ in
                acceptPendingInvitations()
            }
            .task {
                acceptPendingInvitations()
            }
            .background(ShareAcceptanceErrorAlert())
    }

    private func acceptPendingInvitations() {
        let metadata = ShareAcceptanceCenter.shared.pendingMetadata
        guard metadata.isEmpty == false else { return }
        ShareAcceptanceCenter.shared.pendingMetadata = []
        Task {
            do {
                try await HouseholdSharingService.accept(metadata, from: modelContext)
            } catch {
                ShareAcceptanceCenter.shared.errorMessage = error.localizedDescription
                ShareAcceptanceCenter.shared.isErrorPresented = true
            }
        }
    }
}

private struct ShareAcceptanceErrorAlert: View {
    var body: some View {
        @Bindable var center = ShareAcceptanceCenter.shared
        Color.clear
            .frame(width: 0, height: 0)
            .alert("Partage", isPresented: $center.isErrorPresented) {
                Button("OK", role: .cancel) {
                    center.errorMessage = nil
                    center.isErrorPresented = false
                }
            } message: {
                Text(center.errorMessage ?? "")
            }
    }
}

extension View {
    func observesCloudKitShareAcceptance() -> some View {
        modifier(ShareAcceptanceObserver())
    }
}
