import SwiftUI

struct DSTagGlyph: View {
    let symbolName: String
    let colorHex: String

    var body: some View {
        Image(systemName: symbolName)
            .font(.caption)
            .foregroundStyle(ColorHex.contrastingForeground(from: colorHex))
            .frame(width: 22, height: 22)
            .background(ColorHex.color(from: colorHex), in: Circle())
            .accessibilityHidden(true)
    }
}

#Preview {
    HStack {
        DSTagGlyph(symbolName: "cart", colorHex: "#5B8DEF")
        DSTagGlyph(symbolName: "heart", colorHex: "#F4E4C1")
    }
    .padding()
}
