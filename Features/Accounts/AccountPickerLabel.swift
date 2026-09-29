import SwiftUI

struct AccountPickerLabel: View {
    let title: String
    let number: String
    let bank: String

    var body: some View {
        HStack(alignment: .center, spacing: SpacingTokens.sm) {
            DSBankLogo(imageName: BankBrand.resolved(from: bank)?.imageName, size: 20)
                .padding(SpacingTokens.xs)
            VStack(alignment: .leading, spacing: 0) {
                Text(title)
                    .font(.body)
                    .lineLimit(1)
                if number.isEmpty == false {
                    Text(number)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            .multilineTextAlignment(.leading)
        }
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue(number)
    }
}

#Preview {
    AccountPickerLabel(title: "Compte courant", number: "FR76 3000 4000 1071", bank: "BNP Paribas")
        .padding()
}
