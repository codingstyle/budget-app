import SwiftData
import SwiftUI

struct MainSplitView: View {
    @Environment(AppSession.self) private var session
    @State private var importViewModel = ImportCoordinatorViewModel()
    @State private var isRulesInspectorPresented = false

    var body: some View {
        @Bindable var session = session
        NavigationSplitView {
            SidebarView()
                .navigationSplitViewColumnWidth(min: 220, ideal: 250, max: 340)
        } detail: {
            OperationsWorkspaceView()
        }
        .navigationTitle("Budget")
        .inspector(isPresented: $isRulesInspectorPresented) {
            RulesInspectorView()
                .inspectorColumnWidth(min: 220, ideal: 280, max: 400)
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                OperationsSearchField(text: $session.operationSearchText)
            }
            ToolbarItemGroup(placement: .primaryAction) {
                Button("Règles", systemImage: "sidebar.trailing") {
                    isRulesInspectorPresented.toggle()
                }
                .help(isRulesInspectorPresented ? "Masquer les règles" : "Afficher les règles")
                ImportToolbarButton(viewModel: importViewModel)
                HouseholdSharingButton()
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if let status = importViewModel.statusMessage {
                Text(status)
                    .font(.caption)
                    .foregroundStyle(ColorTokens.secondaryText)
                    .padding(.horizontal, SpacingTokens.lg)
                    .padding(.vertical, SpacingTokens.sm)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

}
