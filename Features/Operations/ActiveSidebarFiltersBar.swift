import SwiftUI

struct ActiveSidebarFiltersBar: View {
    let filters: [ActiveSidebarFilter]
    let onClear: (ActiveSidebarFilter) -> Void

    var body: some View {
        if filters.isEmpty == false {
            ScrollView(.horizontal) {
                HStack(spacing: SpacingTokens.sm) {
                    ForEach(filters) { filter in
                        ActiveSidebarFilterChip(
                            filter: filter,
                            onClear: filter.canClear ? { onClear(filter) } : nil
                        )
                    }
                }
            }
            .scrollIndicators(.hidden)
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Filtres actifs")
        }
    }
}
