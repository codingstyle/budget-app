import SwiftUI

struct DSColorPaletteGrid: View {
    @Binding var hex: String
    var onSelect: (() -> Void)?

    private let swatchSize: CGFloat = 16

    var body: some View {
        VStack(alignment: .leading, spacing: SpacingTokens.xs) {
            ForEach(TailwindPalette.families) { family in
                HStack(spacing: 3) {
                    Text(family.name)
                        .font(.caption2)
                        .foregroundStyle(ColorTokens.secondaryText)
                        .frame(width: 52, alignment: .leading)
                    ForEach(family.shades) { shade in
                        swatch(shade, family: family.name)
                    }
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Palette de couleurs")
    }

    private func swatch(_ shade: TailwindColorShade, family: String) -> some View {
        let isSelected = TailwindPalette.normalized(hex) == TailwindPalette.normalized(shade.hex)
        return Button {
            hex = shade.displayHex
            onSelect?()
        } label: {
            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .fill(ColorHex.color(from: shade.hex))
                .frame(width: swatchSize, height: swatchSize)
                .overlay {
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .strokeBorder(isSelected ? Color.primary : Color.black.opacity(0.12), lineWidth: isSelected ? 2 : 0.5)
                }
        }
        .buttonStyle(.plain)
        .help("\(family) \(shade.step)")
        .accessibilityLabel("\(family) \(shade.step)")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    DSColorPaletteGrid(hex: .constant(TailwindPalette.defaultHex))
        .padding()
}
