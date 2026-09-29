import SwiftUI

struct DSSymbolPicker: View {
    @Binding var symbolName: String
    @State private var isPalettePresented = false

    var body: some View {
        LabeledContent("Icône") {
            Button(action: presentPalette) {
                Image(systemName: symbolName)
                    .font(.body)
                    .frame(width: 22, height: 22)
                    .foregroundStyle(.primary)
            }
            .buttonStyle(.plain)
            .help("Choisir une icône")
            .accessibilityLabel("Icône")
            .accessibilityValue(symbolName)
            .popover(isPresented: $isPalettePresented, arrowEdge: .bottom) {
                DSSymbolPickerPopover(symbolName: $symbolName, onSelect: dismissPalette)
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
        DSSymbolPicker(symbolName: .constant("tag"))
    }
    .formStyle(.grouped)
    .frame(width: 360)
}
