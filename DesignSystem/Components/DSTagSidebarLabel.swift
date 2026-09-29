import SwiftUI

struct DSTagSidebarLabel: View {
    let title: String
    let symbolName: String
    let colorHex: String

    var body: some View {
        Label {
            Text(title)
                .foregroundStyle(.black)
                .lineLimit(1)
        } icon: {
            DSTagGlyph(symbolName: symbolName, colorHex: colorHex)
        }
        .accessibilityLabel(title)
    }
}

#Preview {
    VStack(alignment: .leading, spacing: SpacingTokens.sm) {
        DSTagSidebarLabel(title: "Alimentation", symbolName: "cart", colorHex: "#5B8DEF")
        DSTagSidebarLabel(title: "Santé", symbolName: "heart", colorHex: "#F4E4C1")
    }
    .padding()
}
