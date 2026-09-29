import SwiftData
import SwiftUI

struct EnseignesSidebarView: View {
    let filterText: String
    let addToken: Int

    @Query(sort: \Enseigne.name) private var enseignes: [Enseigne]
    @Query private var households: [Household]
    @Environment(AppSession.self) private var session
    @State private var enseigneBeingEdited: Enseigne?
    @State private var isCreatingEnseigne = false

    var body: some View {
        VStack(alignment: .leading, spacing: SpacingTokens.xs) {
            Button(action: clearFilter) {
                HStack(alignment: .center, spacing: SpacingTokens.sm) {
                    DSEnseigneLogo(imageData: nil, size: 16)
                    Text("Toutes les enseignes")
                        .font(.body)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, SpacingTokens.sm)
                .padding(.vertical, SpacingTokens.xs)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    session.selectedEnseigneID == nil ? ColorTokens.accent.opacity(0.16) : Color.clear,
                    in: RoundedRectangle(cornerRadius: 6, style: .continuous)
                )
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .padding(.horizontal, SpacingTokens.sm)
            .accessibilityLabel("Toutes les enseignes")
            .accessibilityAddTraits(session.selectedEnseigneID == nil ? .isSelected : [])

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 2) {
                    ForEach(filteredEnseignes) { enseigne in
                        EnseigneSidebarRow(
                            enseigne: enseigne,
                            isSelected: session.selectedEnseigneID == enseigne.persistentModelID,
                            onSelect: { toggle(enseigne) },
                            onEdit: { enseigneBeingEdited = enseigne }
                        )
                    }
                }
                .padding(.horizontal, SpacingTokens.sm)
                .padding(.bottom, SpacingTokens.sm)
            }
        }
        .padding(.top, SpacingTokens.sm)
        .onChange(of: addToken) { _, _ in
            presentCreator()
        }
        .sheet(item: $enseigneBeingEdited) { enseigne in
            NavigationStack {
                EnseigneEditorView(enseigne: enseigne, household: enseigne.household ?? households.first)
            }
        }
        .sheet(isPresented: $isCreatingEnseigne) {
            AddEnseigneView(household: households.first)
        }
    }

    private func presentCreator() {
        isCreatingEnseigne = true
    }

    private var filteredEnseignes: [Enseigne] {
        let query = filterText.trimmingCharacters(in: .whitespacesAndNewlines)
        let visible: [Enseigne]
        if query.isEmpty {
            visible = Array(enseignes)
        } else {
            visible = enseignes.filter { $0.name.localizedStandardContains(query) }
        }
        return visible.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }

    private func clearFilter() {
        session.selectedEnseigneID = nil
    }

    private func toggle(_ enseigne: Enseigne) {
        if session.selectedEnseigneID == enseigne.persistentModelID {
            session.selectedEnseigneID = nil
        } else {
            session.selectedEnseigneID = enseigne.persistentModelID
        }
    }
}
