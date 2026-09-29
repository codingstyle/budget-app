import SwiftData
import SwiftUI

struct RulesInspectorView: View {
    @Query private var households: [Household]
    @State private var filterText = ""
    @State private var addToken = 0

    var body: some View {
        VStack(spacing: 0) {
            Text("Filtres")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, SpacingTokens.md)
                .padding(.vertical, SpacingTokens.sm)
            RulesSidebarView(filterText: filterText, addToken: addToken)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            SidebarListFooter(
                filterPrompt: "Filtrer les règles",
                addLabel: "Ajouter une règle",
                filterText: $filterText,
                canAdd: households.first != nil,
                onAdd: requestAdd
            )
        }
        .background {
            Rectangle()
                .fill(.thinMaterial)
                .ignoresSafeArea()
        }
        .navigationTitle("Filtres")
    }

    private func requestAdd() {
        addToken += 1
    }
}
