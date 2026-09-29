import SwiftData
import SwiftUI

struct LearningRuleRow: View {
    let rule: LabelRule

    var body: some View {
        VStack(alignment: .leading, spacing: SpacingTokens.sm) {
            labeledRow(title: "Si le libellé contient") {
                Text(matchSummary)
                    .textSelection(.enabled)
            }

            labeledRow(title: "Assigner l’enseigne") {
                if let enseigne = rule.enseigne {
                    HStack(spacing: SpacingTokens.sm) {
                        DSEnseigneLogo(imageData: enseigne.logoData, size: 20)
                        Text(enseigne.name)
                            .lineLimit(1)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(enseigne.name)
                } else {
                    Text("—")
                        .foregroundStyle(ColorTokens.secondaryText)
                }
            }

            labeledRow(title: "Assigner les tags") {
                if sortedTags.isEmpty {
                    Text("—")
                        .foregroundStyle(ColorTokens.secondaryText)
                } else {
                    HStack(spacing: SpacingTokens.xs) {
                        ForEach(sortedTags) { tag in
                            DSTagChip(
                                title: tag.label,
                                symbolName: tag.symbolName,
                                colorHex: tag.colorHex,
                                isCompact: true
                            )
                        }
                    }
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel(sortedTags.map(\.label).joined(separator: ", "))
                }
            }
        }
        .padding(.vertical, SpacingTokens.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var matchSummary: String {
        let texts = rule.matchTexts
        guard texts.isEmpty == false else { return "—" }
        return texts.joined(separator: " ou ")
    }

    private var sortedTags: [Tag] {
        (rule.tags ?? []).sorted { $0.label.localizedStandardCompare($1.label) == .orderedAscending }
    }

    private func labeledRow<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: SpacingTokens.sm) {
            Text("\(title) :")
                .foregroundStyle(ColorTokens.secondaryText)
                .frame(width: 180, alignment: .leading)
            content()
            Spacer(minLength: 0)
        }
    }
}
