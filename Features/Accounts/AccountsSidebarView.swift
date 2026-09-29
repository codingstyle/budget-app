import SwiftData
import SwiftUI

struct AccountsSidebarView: View {
    let filterText: String
    let addToken: Int

    @Query(sort: \BankAccount.label) private var accounts: [BankAccount]
    @Environment(AppSession.self) private var session
    @State private var isAddingAccount = false

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 2) {
                ForEach(filteredAccounts) { account in
                    Button {
                        select(account)
                    } label: {
                        AccountPickerLabel(title: account.label, number: account.number, bank: account.bank)
                            .padding(.horizontal, SpacingTokens.sm)
                            .padding(.vertical, SpacingTokens.xs)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                account.persistentModelID == session.selectedAccountID
                                    ? ColorTokens.accent.opacity(0.16)
                                    : Color.clear,
                                in: RoundedRectangle(cornerRadius: 6, style: .continuous)
                            )
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(account.persistentModelID == session.selectedAccountID ? .isSelected : [])
                }
            }
            .padding(.horizontal, SpacingTokens.sm)
            .padding(.vertical, SpacingTokens.sm)
        }
        .onAppear(perform: ensureSelection)
        .onChange(of: accounts.count) {
            ensureSelection()
        }
        .onChange(of: addToken) { _, _ in
            isAddingAccount = true
        }
        .sheet(isPresented: $isAddingAccount) {
            AddAccountView(onCreated: select)
        }
    }

    private var filteredAccounts: [BankAccount] {
        let needle = filterText.trimmingCharacters(in: .whitespacesAndNewlines)
        let visible: [BankAccount]
        if needle.isEmpty {
            visible = Array(accounts)
        } else {
            visible = accounts.filter { account in
                account.label.localizedStandardContains(needle)
                    || account.number.localizedStandardContains(needle)
                    || account.bank.localizedStandardContains(needle)
            }
        }
        return visible.sorted { $0.label.localizedStandardCompare($1.label) == .orderedAscending }
    }

    private func select(_ account: BankAccount) {
        session.selectedAccountID = account.persistentModelID
    }

    private func ensureSelection() {
        if let selected = session.selectedAccountID,
           accounts.contains(where: { $0.persistentModelID == selected }) {
            return
        }
        session.selectedAccountID = accounts.first?.persistentModelID
    }
}
