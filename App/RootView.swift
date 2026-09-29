import SwiftData
import SwiftUI

struct RootView: View {
    @Query(sort: \BankAccount.label) private var accounts: [BankAccount]
    @Environment(\.modelContext) private var modelContext
    @Environment(AppSession.self) private var session

    var body: some View {
        Group {
            if accounts.isEmpty {
                OnboardingView()
            } else {
                MainSplitView()
            }
        }
        .environment(\.masksAmounts, session.masksAmounts)
        .task {
            _ = HouseholdBootstrap.loadOrCreate(in: modelContext)
            CardStore.linkOperations(in: modelContext)
            if session.selectedAccountID == nil {
                session.selectedAccountID = accounts.first?.persistentModelID
            }
        }
        .observesCloudKitShareAcceptance()
        .modifier(AccountDebugSceneBridge())
    }
}
