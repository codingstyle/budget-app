import SwiftUI

struct OperationsDisplayStylePicker: View {
    @Binding var selection: OperationsDisplayStyle

    var body: some View {
        Picker("Affichage", selection: $selection) {
            ForEach(OperationsDisplayStyle.allCases) { style in
                Image(systemName: style.systemImage)
                    .tag(style)
                    .help(style.title)
                    .accessibilityLabel(style.title)
            }
        }
        .pickerStyle(.segmented)
        .labelsHidden()
        .frame(maxWidth: 88)
        .accessibilityLabel("Affichage")
    }
}
