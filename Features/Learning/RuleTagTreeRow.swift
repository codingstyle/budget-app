import SwiftData
import SwiftUI

struct RuleTagTreeRow: View {
    let tag: Tag
    let isSelected: Bool
    let onToggle: (Tag) -> Void

    var body: some View {
        Button {
            onToggle(tag)
        } label: {
            DSTagSidebarLabel(
                title: tag.label,
                symbolName: tag.symbolName,
                colorHex: tag.colorHex
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, SpacingTokens.xs)
            .background(
                isSelected ? ColorTokens.accent.opacity(0.16) : Color.clear,
                in: RoundedRectangle(cornerRadius: 6)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
