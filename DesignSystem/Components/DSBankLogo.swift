import SwiftUI

struct DSBankLogo: View {
    let imageName: String?
    var size: CGFloat = 32

    var body: some View {
        Group {
            if let imageName {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
            } else {
                Image(systemName: "building.columns.fill")
                    .resizable()
                    .scaledToFit()
                    .padding(4)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: size * 0.2, style: .continuous))
        .accessibilityHidden(true)
    }
}

#Preview {
    HStack {
        DSBankLogo(imageName: "logo_bnp_paribas")
        DSBankLogo(imageName: "logo_credit_agricole")
        DSBankLogo(imageName: nil)
    }
    .padding()
}
