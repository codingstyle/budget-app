import SwiftData
import SwiftUI

struct TagTreeRow: View {
    let tag: Tag
    let isSelected: Bool
    let onSelect: (Tag) -> Void
    let onEdit: (Tag) -> Void
    let onAddChild: (Tag) -> Void

    var body: some View {
        Button {
            onSelect(tag)
        } label: {
            DSTagSidebarLabel(
                title: tag.label,
                symbolName: tag.symbolName,
                colorHex: tag.colorHex
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, SpacingTokens.sm)
            .padding(.vertical, SpacingTokens.xs)
            .background(
                isSelected ? ColorTokens.accent.opacity(0.16) : Color.clear,
                in: RoundedRectangle(cornerRadius: 6)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button("Modifier") {
                onEdit(tag)
            }
            Button("Ajouter un sous-tag") {
                onAddChild(tag)
            }
        }
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
