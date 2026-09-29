import SwiftUI

struct DSSymbolPickerPopover: View {
    @Binding var symbolName: String
    var onSelect: (() -> Void)?

    @State private var searchText = ""
    @FocusState private var isSearchFocused: Bool

    private let columns = [GridItem(.adaptive(minimum: 28), spacing: SpacingTokens.xs)]

    var body: some View {
        VStack(spacing: 0) {
            TextField("Rechercher une icône", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .controlSize(.small)
                .focused($isSearchFocused)
                .padding(SpacingTokens.sm)
                .accessibilityLabel("Rechercher une icône")

            Divider()

            if filteredNames.isEmpty {
                Text("Aucune icône")
                    .font(.caption)
                    .foregroundStyle(ColorTokens.secondaryText)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: SpacingTokens.xs) {
                        ForEach(filteredNames, id: \.self) { name in
                            Button {
                                symbolName = name
                                onSelect?()
                            } label: {
                                Image(systemName: name)
                                    .font(.body)
                                    .frame(width: 28, height: 28)
                                    .background(
                                        symbolName == name ? ColorTokens.accent.opacity(0.2) : Color.clear,
                                        in: RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    )
                            }
                            .buttonStyle(.plain)
                            .help(name)
                            .accessibilityLabel(name)
                            .accessibilityAddTraits(symbolName == name ? .isSelected : [])
                        }
                    }
                    .padding(SpacingTokens.sm)
                }
            }
        }
        .frame(width: 340, height: 400)
        .onAppear {
            isSearchFocused = true
        }
    }

    private var filteredNames: [String] {
        let needle = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard needle.isEmpty == false else { return SFSymbolCatalog.names }
        return SFSymbolCatalog.names.filter { $0.localizedStandardContains(needle) }
    }
}

#Preview {
    DSSymbolPickerPopover(symbolName: .constant("tag"))
}
