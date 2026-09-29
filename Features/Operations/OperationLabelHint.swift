import SwiftUI

struct OperationLabelHint: View {
    let originalLabel: String
    @State private var isShowingTooltip = false

    var body: some View {
        if originalLabel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false {
            Image(systemName: "info.circle")
                .foregroundStyle(ColorTokens.secondaryText)
                .frame(width: 16, height: 16)
                .contentShape(Rectangle())
                .onHover(perform: setHovering)
                .popover(isPresented: $isShowingTooltip, arrowEdge: .trailing) {
                    Text(originalLabel)
                        .font(.callout)
                        .textSelection(.enabled)
                        .padding(SpacingTokens.md)
                        .frame(maxWidth: 360, alignment: .leading)
                }
                .accessibilityLabel("Libellé d’origine")
                .accessibilityValue(originalLabel)
        }
    }

    private func setHovering(_ hovering: Bool) {
        isShowingTooltip = hovering
    }
}
