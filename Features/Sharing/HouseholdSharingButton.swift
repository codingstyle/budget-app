import SwiftData
import SwiftUI

struct HouseholdSharingButton: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var households: [Household]
    @State private var errorMessage: String?
    @State private var isErrorPresented = false
    @State private var isWorking = false

    var body: some View {
        Button("Partager le foyer", systemImage: "person.2", action: shareHousehold)
            .disabled(isWorking || households.first == nil)
            .alert(
                "Partage",
                isPresented: $isErrorPresented
            ) {
                Button("OK", role: .cancel) {
                    errorMessage = nil
                    isErrorPresented = false
                }
            } message: {
                Text(errorMessage ?? "")
            }
    }

    private func shareHousehold() {
        guard let household = households.first else { return }
        isWorking = true
        Task {
            defer { isWorking = false }
            do {
                let result = try await HouseholdSharingService.share(household, from: modelContext)
                CloudSharePanel.present(share: result.0, container: result.1)
            } catch {
                errorMessage = error.localizedDescription
                isErrorPresented = true
            }
        }
    }
}
