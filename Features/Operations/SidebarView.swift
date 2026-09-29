import SwiftData
import SwiftUI

struct SidebarView: View {
    @Query private var households: [Household]
    @State private var section: SidebarSection = .tags
    @State private var filterText = ""
    @State private var addToken = 0

    var body: some View {
        VStack(spacing: 0) {
            SidebarTabBar(selection: $section)
            tabContent
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            SidebarListFooter(
                filterPrompt: section.filterPrompt,
                addLabel: section.addLabel,
                filterText: $filterText,
                canAdd: households.first != nil,
                onAdd: requestAdd
            )
        }
        .background(ColorTokens.sidebar.ignoresSafeArea())
        .onChange(of: section) { _, _ in
            filterText = ""
        }
    }

    @ViewBuilder
    private var tabContent: some View {
        switch section {
        case .accounts:
            AccountsSidebarView(filterText: filterText, addToken: addToken)
        case .cards:
            CardsSidebarView(filterText: filterText, addToken: addToken)
        case .tags:
            TagsSidebarView(filterText: filterText, addToken: addToken)
        case .enseignes:
            EnseignesSidebarView(filterText: filterText, addToken: addToken)
        }
    }

    private func requestAdd() {
        addToken += 1
    }
}
