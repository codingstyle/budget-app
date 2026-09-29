import SwiftUI

struct CardTypePicker: View {
    @Binding var selection: CardType

    var body: some View {
        Picker("Type", selection: $selection) {
            ForEach(CardType.allCases) { type in
                CardTypePickerRow(type: type)
                    .tag(type)
            }
        }
    }
}

#Preview {
    CardTypePicker(selection: .constant(.visaPremier))
        .padding()
}
