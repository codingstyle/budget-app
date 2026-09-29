import SwiftData
import SwiftUI

struct RulesSidebarRow: View {
    let rule: LabelRule

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(matchSummary)
                .font(.caption)
                .lineLimit(2)
                .foregroundStyle(.primary)

            HStack(spacing: SpacingTokens.xs) {
                if let enseigne = rule.enseigne {
                    DSEnseigneLogo(imageData: enseigne.logoData, size: 14)
                    Text(enseigne.name)
                        .lineLimit(1)
                }
                ForEach(sortedTags.prefix(3)) { tag in
                    DSTagChip(
                        title: tag.label,
                        symbolName: tag.symbolName,
                        colorHex: tag.colorHex,
                        isCompact: true
                    )
                }
            }
            .font(.caption2)
            .foregroundStyle(ColorTokens.secondaryText)
        }
        .padding(.horizontal, SpacingTokens.sm)
        .padding(.vertical, SpacingTokens.xs)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilitySummary)
    }

    private var matchSummary: String {
        let texts = rule.matchTexts
        guard texts.isEmpty == false else { return "—" }
        return texts.joined(separator: " ou ")
    }

    private var sortedTags: [Tag] {
        (rule.tags ?? []).sorted { $0.label.localizedStandardCompare($1.label) == .orderedAscending }
    }

    private var accessibilitySummary: String {
        var parts = ["Règle", matchSummary]
        if let name = rule.enseigne?.name {
            parts.append(name)
        }
        parts.append(contentsOf: sortedTags.map(\.label))
        return parts.joined(separator: ", ")
    }
}
