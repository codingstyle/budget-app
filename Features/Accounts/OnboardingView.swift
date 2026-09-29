import SwiftData
import SwiftUI

struct OnboardingView: View {
    @Environment(AppSession.self) private var session

    var body: some View {
        VStack(spacing: SpacingTokens.xl) {
            DSEmptyState(
                title: "Bienvenue dans Budget",
                message: "Ajoutez un premier compte bancaire pour importer vos opérations et suivre vos dépenses.",
                systemImage: "building.columns"
            )
            AddAccountView(isOnboarding: true, onCreated: { account in
                session.selectedAccountID = account.persistentModelID
            })
        }
        .padding(SpacingTokens.xxl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ColorTokens.background)
    }
}

#Preview {
    OnboardingView()
        .environment(AppSession())
        .modelContainer(BudgetModelContainer.make())
}
