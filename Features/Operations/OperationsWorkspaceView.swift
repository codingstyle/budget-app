import SwiftData
import SwiftUI

struct OperationsWorkspaceView: View {
    @Environment(AppSession.self) private var session
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Operation.effectDate, order: .reverse) private var operations: [Operation]
    @Query(sort: \BankAccount.label) private var accounts: [BankAccount]
    @Query(sort: \Tag.label) private var tags: [Tag]
    @Query(sort: \Enseigne.name) private var enseignes: [Enseigne]
    @Query private var households: [Household]
    @Query private var cards: [Card]
    @State private var taggingViewModel = OperationsTaggingViewModel()
    @State private var selectedOperationIDs: Set<PersistentIdentifier> = []
    @State private var isCreatingTag = false
    @State private var isAddingRule = false
    @State private var ruleMatchText = ""
    @State private var creditForRefundLink: Operation?

    var body: some View {
        @Bindable var session = session
        VStack(alignment: .leading, spacing: SpacingTokens.md) {
            ActiveSidebarFiltersBar(filters: activeSidebarFilters, onClear: clearSidebarFilter)
            OperationsFilterBar(
                monthYear: $session.monthYear,
                displayStyle: $session.operationsDisplayStyle,
                balance: selectedAccount?.lastKnownBalance,
                totals: OperationPeriodTotals(operations: filteredOperations)
            )
            switch session.operationsDisplayStyle {
            case .list:
                if displayedOperations.isEmpty {
                    DSEmptyState(
                        title: emptyTitle,
                        message: emptyMessage,
                        systemImage: "tray"
                    )
                } else {
                    OperationsTableView(
                        operations: displayedOperations,
                        tags: tags,
                        selection: $selectedOperationIDs,
                        onApplyTag: applyTag,
                        onCreateTag: presentTagCreator,
                        onCreateRule: presentRuleCreator,
                        onAssociateRefund: presentRefundLink,
                        onUnlinkRefund: unlinkRefund
                    )
                }
            case .charts:
                ExpenseChartsView(
                    historyOperations: historyOperations,
                    monthOperations: monthOperations,
                    monthYear: session.monthYear,
                    selectedTag: selectedTag
                )
            }
        }
        .padding(SpacingTokens.lg)
        .onChange(of: session.selectedAccountID, clearSelection)
        .onChange(of: session.selectedCardID, clearSelection)
        .onChange(of: session.monthYear, clearSelection)
        .onChange(of: session.selectedTagID, clearSelection)
        .onChange(of: session.selectedEnseigneID, clearSelection)
        .onChange(of: session.operationSearchText, clearSelection)
        .sheet(isPresented: $isCreatingTag, content: newTagSheet)
        .sheet(isPresented: $isAddingRule, content: newRuleSheet)
        .sheet(item: $creditForRefundLink, content: refundLinkSheet)
    }

    private var selectedAccount: BankAccount? {
        accounts.first { $0.persistentModelID == session.selectedAccountID }
    }

    private var selectedCard: Card? {
        cards.first { $0.persistentModelID == session.selectedCardID }
    }

    private var selectedTag: Tag? {
        tags.first { $0.persistentModelID == session.selectedTagID }
    }

    private var selectedEnseigne: Enseigne? {
        enseignes.first { $0.persistentModelID == session.selectedEnseigneID }
    }

    private var activeSidebarFilters: [ActiveSidebarFilter] {
        var filters: [ActiveSidebarFilter] = []
        if let selectedAccount {
            filters.append(.account(selectedAccount))
        }
        if let selectedCard {
            filters.append(.card(selectedCard))
        }
        if let selectedTag {
            filters.append(.tag(selectedTag))
        }
        if let selectedEnseigne {
            filters.append(.enseigne(selectedEnseigne))
        }
        return filters
    }

    private var filteredOperations: [Operation] {
        operations.filter { operation in
            guard matchesPersistentFilters(operation) else { return false }
            let search = session.operationSearchText.trimmingCharacters(in: .whitespacesAndNewlines)
            if search.isEmpty {
                return session.monthYear.contains(operation.effectDate)
            }
            return operation.matchesSearch(search)
        }
    }

    private var historyOperations: [Operation] {
        operations.filter(matchesPersistentFilters)
    }

    private var monthOperations: [Operation] {
        historyOperations.filter { session.monthYear.contains($0.effectDate) }
    }

    private func matchesPersistentFilters(_ operation: Operation) -> Bool {
        guard operation.account?.persistentModelID == session.selectedAccountID else {
            return false
        }
        if let cardID = session.selectedCardID {
            let selectedCard = cards.first { $0.persistentModelID == cardID }
            let lastFour = selectedCard?.lastFour ?? ""
            let matchesRelationship = operation.card?.persistentModelID == cardID
            let matchesLabel = lastFour.isEmpty == false && operation.cardLastFour == lastFour
            guard matchesRelationship || matchesLabel else {
                return false
            }
        }
        if let enseigneID = session.selectedEnseigneID {
            guard operation.enseigne?.persistentModelID == enseigneID else {
                return false
            }
        }
        if let tagID = session.selectedTagID {
            let matchingIDs = Set(tags.first { $0.persistentModelID == tagID }?.descendantIDs ?? [tagID])
            return operation.tags?.contains { matchingIDs.contains($0.persistentModelID) } == true
        }
        return true
    }

    private var displayedOperations: [Operation] {
        RefundMatcher.groupedForDisplay(filteredOperations)
    }

    private var accountOperations: [Operation] {
        operations.filter { $0.account?.persistentModelID == session.selectedAccountID }
    }

    private var isSearching: Bool {
        session.operationSearchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
    }

    private var emptyTitle: String {
        isSearching ? "Aucun résultat" : "Aucune opération"
    }

    private var emptyMessage: String {
        if isSearching {
            return "Aucune opération ne correspond à « \(session.operationSearchText.trimmingCharacters(in: .whitespacesAndNewlines)) »."
        }
        return "Importez un export Excel BNP Paribas ou changez de période."
    }

    private func selectedOperations() -> [Operation] {
        let ids = selectedOperationIDs
        return displayedOperations.filter { ids.contains($0.persistentModelID) }
    }

    private func applyTag(_ tag: Tag) {
        taggingViewModel.apply(tag, to: selectedOperations(), in: modelContext)
    }

    private func presentTagCreator() {
        isCreatingTag = true
    }

    private func clearSidebarFilter(_ filter: ActiveSidebarFilter) {
        switch filter {
        case .account:
            break
        case .card:
            session.selectedCardID = nil
        case .tag:
            session.selectedTagID = nil
        case .enseigne:
            session.selectedEnseigneID = nil
        }
    }

    private func presentRefundLink(from credit: Operation) {
        creditForRefundLink = credit
    }

    private func unlinkRefund(_ credit: Operation) {
        try? RefundLinkService.unlink(credit: credit, in: modelContext)
    }

    private func presentRuleCreator(from operation: Operation) {
        let parsed = operation.displayLabel.trimmingCharacters(in: .whitespacesAndNewlines)
        ruleMatchText = parsed.isEmpty ? operation.originalLabel : parsed
        isAddingRule = true
    }

    private func clearSelection() {
        selectedOperationIDs = []
    }

    @ViewBuilder
    private func newTagSheet() -> some View {
        if let household = selectedAccount?.household ?? households.first {
            NavigationStack {
                TagEditorView(
                    tag: nil,
                    household: household,
                    availableTags: tags,
                    onSaved: applyTag
                )
            }
        }
    }

    @ViewBuilder
    private func newRuleSheet() -> some View {
        if let household = selectedAccount?.household ?? households.first {
            NavigationStack {
                AddRuleView(household: household, matchText: ruleMatchText)
            }
        }
    }

    @ViewBuilder
    private func refundLinkSheet(_ credit: Operation) -> some View {
        RefundManualLinkView(credit: credit, operations: accountOperations)
    }
}
