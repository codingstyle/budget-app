import SwiftData
import SwiftUI

struct EnseigneSidebarRow: View {
    let enseigne: Enseigne
    let isSelected: Bool
    let onSelect: () -> Void
    let onEdit: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: SpacingTokens.sm) {
                DSEnseigneLogo(imageData: enseigne.logoData, size: 16)
                Text(enseigne.name)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, SpacingTokens.sm)
            .padding(.vertical, SpacingTokens.xs)
            .background(isSelected ? ColorTokens.accent.opacity(0.16) : Color.clear, in: RoundedRectangle(cornerRadius: 6, style: .continuous))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button("Modifier", action: onEdit)
        }
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
