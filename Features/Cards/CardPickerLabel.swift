import SwiftUI

struct CardPickerLabel: View {
    let title: String
    let number: String
    let imageName: String?

    var body: some View {
        HStack(alignment: .center, spacing: SpacingTokens.sm) {
            DSCardLogo(imageName: imageName, maxHeight: 16)
                .padding(.vertical, SpacingTokens.xs)
            VStack(alignment: .leading, spacing: 0) {
                Text(title)
                    .font(.body)
                    .lineLimit(1)
                    .truncationMode(.tail)
                if number.isEmpty == false {
                    Text(number)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .multilineTextAlignment(.leading)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue(number)
    }
}

#Preview {
    VStack(alignment: .leading) {
        CardPickerLabel(title: "Toutes les cartes", number: "", imageName: nil)
        CardPickerLabel(title: "Christophe Buguet", number: "XXXX XXXX XXXX 3054", imageName: "logo_visa_premier")
    }
    .padding()
}
