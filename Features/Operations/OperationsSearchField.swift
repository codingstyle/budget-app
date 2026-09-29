import AppKit
import SwiftUI

struct OperationsSearchField: View {
    @Binding var text: String

    var body: some View {
        HStack(spacing: SpacingTokens.sm) {
            TextField("Rechercher des opérations", text: $text)
                .textFieldStyle(.plain)
            if text.isEmpty == false {
                Button("Effacer", systemImage: "xmark.circle.fill", action: clear)
                    .labelStyle(.iconOnly)
                    .buttonStyle(.plain)
                    .foregroundStyle(ColorTokens.secondaryText)
                    .help("Effacer la recherche")
            }
        }
        .padding(.horizontal, SpacingTokens.md)
        .padding(.vertical, SpacingTokens.xs)
        .frame(minWidth: 220, idealWidth: 280, maxWidth: 360)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color(nsColor: .textBackgroundColor))
        )
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Rechercher des opérations")
    }

    private func clear() {
        text = ""
    }
}

#Preview {
    VStack(spacing: 16) {
        OperationsSearchField(text: .constant(""))
        OperationsSearchField(text: .constant("CARREFOUR"))
    }
    .padding()
}
