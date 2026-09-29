import SwiftUI

struct SidebarListFooter: View {
    let filterPrompt: String
    let addLabel: String
    @Binding var filterText: String
    let canAdd: Bool
    let onAdd: () -> Void

    var body: some View {
        HStack(spacing: SpacingTokens.sm) {
            Button(addLabel, systemImage: "plus", action: onAdd)
                .labelStyle(.iconOnly)
                .disabled(canAdd == false)
                .help(addLabel)

            TextField(filterPrompt, text: $filterText)
                .textFieldStyle(.roundedBorder)
                .controlSize(.small)
                .accessibilityLabel(filterPrompt)
        }
        .padding(.horizontal, SpacingTokens.sm)
        .padding(.vertical, SpacingTokens.sm)
        .overlay(alignment: .top) {
            Divider()
        }
    }
}

#Preview {
    SidebarListFooter(
        filterPrompt: "Filtrer les étiquettes",
        addLabel: "Ajouter une étiquette",
        filterText: .constant(""),
        canAdd: true,
        onAdd: {}
    )
        .frame(width: 220)
}
