import SwiftUI

struct DSColorPalettePicker: View {
    @Binding var hex: String
    @State private var isPalettePresented = false

    var body: some View {
        LabeledContent("Couleur") {
            Button(action: presentPalette) {
                Circle()
                    .fill(ColorHex.color(from: hex))
                    .frame(width: 22, height: 22)
                    .overlay {
                        Circle()
                            .strokeBorder(Color.primary.opacity(0.25), lineWidth: 1)
                    }
            }
            .buttonStyle(.plain)
            .help("Choisir une couleur")
            .accessibilityLabel("Couleur")
            .accessibilityValue(hex)
            .popover(isPresented: $isPalettePresented, arrowEdge: .bottom) {
                DSColorPaletteGrid(hex: $hex, onSelect: dismissPalette)
                    .padding(SpacingTokens.md)
            }
        }
    }

    private func presentPalette() {
        isPalettePresented = true
    }

    private func dismissPalette() {
        isPalettePresented = false
    }
}

#Preview {
    Form {
        DSColorPalettePicker(hex: .constant(TailwindPalette.defaultHex))
    }
    .formStyle(.grouped)
    .frame(width: 360)
}
