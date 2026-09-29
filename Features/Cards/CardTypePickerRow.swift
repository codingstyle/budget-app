import SwiftUI

struct CardTypePickerRow: View {
    let type: CardType

    var body: some View {
        Label {
            Text(type.rawValue)
        } icon: {
            DSCardLogo(imageName: type.imageName)
        }
    }
}
