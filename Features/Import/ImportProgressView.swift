import SwiftUI

struct ImportProgressView: View {
    let message: String
    let fraction: Double

    var body: some View {
        VStack(alignment: .leading, spacing: SpacingTokens.md) {
            Text("Import en cours")
                .font(.headline)
            Text(message)
                .foregroundStyle(ColorTokens.secondaryText)
            ProgressView(value: min(max(fraction, 0), 1))
                .progressViewStyle(.linear)
        }
        .padding(SpacingTokens.xl)
        .frame(minWidth: 380)
        .interactiveDismissDisabled()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Import en cours")
        .accessibilityValue(message)
    }
}
