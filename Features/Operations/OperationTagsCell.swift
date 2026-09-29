import SwiftData
import SwiftUI

struct OperationTagsCell: View {
    let operation: Operation

    var body: some View {
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
        .accessibilityLabel(sortedTags.isEmpty ? "Aucune étiquette" : "Étiquettes")
    }

    private var sortedTags: [Tag] {
        (operation.tags ?? []).sorted { $0.label.localizedStandardCompare($1.label) == .orderedAscending }
    }
}
