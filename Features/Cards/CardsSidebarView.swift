import SwiftData
import SwiftUI

struct CardsSidebarView: View {
    let filterText: String
    let addToken: Int

    @Query private var cards: [Card]
    @Environment(AppSession.self) private var session
    @State private var isAddingCard = false
    @State private var cardBeingEdited: Card?

    var body: some View {
        VStack(alignment: .leading, spacing: SpacingTokens.xs) {
            Button(action: selectAll) {
                CardPickerLabel(title: "Toutes les cartes", number: "", imageName: nil)
                    .padding(.horizontal, SpacingTokens.sm)
                    .padding(.vertical, SpacingTokens.xs)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        session.selectedCardID == nil ? ColorTokens.accent.opacity(0.16) : Color.clear,
                        in: RoundedRectangle(cornerRadius: 6, style: .continuous)
                    )
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .padding(.horizontal, SpacingTokens.sm)
            .accessibilityAddTraits(session.selectedCardID == nil ? .isSelected : [])

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 2) {
                    ForEach(filteredCards) { card in
                        Button {
                            select(card)
                        } label: {
                            CardPickerLabel(
                                title: card.cardholderName,
                                number: card.maskedNumber,
                                imageName: card.type.imageName
                            )
                            .padding(.horizontal, SpacingTokens.sm)
                            .padding(.vertical, SpacingTokens.xs)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                card.persistentModelID == session.selectedCardID
                                    ? ColorTokens.accent.opacity(0.16)
                                    : Color.clear,
                                in: RoundedRectangle(cornerRadius: 6, style: .continuous)
                            )
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .contextMenu {
                            Button("Modifier") {
                                cardBeingEdited = card
                            }
                        }
                        .accessibilityAddTraits(card.persistentModelID == session.selectedCardID ? .isSelected : [])
                    }
                }
                .padding(.horizontal, SpacingTokens.sm)
                .padding(.bottom, SpacingTokens.sm)
            }
        }
        .padding(.top, SpacingTokens.sm)
        .onChange(of: addToken) { _, _ in
            isAddingCard = true
        }
        .sheet(isPresented: $isAddingCard) {
            NavigationStack {
                AddCardView(onSaved: select)
            }
        }
        .sheet(item: $cardBeingEdited) { card in
            NavigationStack {
                AddCardView(card: card)
            }
        }
    }

    private var filteredCards: [Card] {
        let needle = filterText.trimmingCharacters(in: .whitespacesAndNewlines)
        let visible: [Card]
        if needle.isEmpty {
            visible = Array(cards)
        } else {
            visible = cards.filter { card in
                card.cardholderName.localizedStandardContains(needle)
                    || card.lastFour.localizedStandardContains(needle)
                    || card.maskedNumber.localizedStandardContains(needle)
            }
        }
        return visible.sorted { $0.cardholderName.localizedStandardCompare($1.cardholderName) == .orderedAscending }
    }

    private func selectAll() {
        session.selectedCardID = nil
    }

    private func select(_ card: Card) {
        session.selectedCardID = card.persistentModelID
    }
}
