import SwiftUI

struct ActiveSidebarFilterChip: View {
    let filter: ActiveSidebarFilter
    var onClear: (() -> Void)?

    var body: some View {
        HStack(spacing: SpacingTokens.sm) {
            ActiveSidebarFilterIcon(filter: filter)
            VStack(alignment: .leading, spacing: -2) {
                Text(filter.category)
                    .font(.caption)
                    .foregroundStyle(ColorTokens.secondaryText)
                Text(filter.title)
                    .lineLimit(1)
            }
            if let onClear {
                Button("Retirer", systemImage: "xmark.circle.fill", action: onClear)
                    .labelStyle(.iconOnly)
                    .buttonStyle(.borderless)
                    .foregroundStyle(ColorTokens.secondaryText)
                    .help("Retirer le filtre \(filter.category.lowercased())")
            }
        }
        .padding(.horizontal, SpacingTokens.md)
        .padding(.vertical, SpacingTokens.xs)
        .background(
            Color.primary.opacity(0.03),
            in: RoundedRectangle(cornerRadius: 8)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(filter.category) \(filter.title)")
    }
}
