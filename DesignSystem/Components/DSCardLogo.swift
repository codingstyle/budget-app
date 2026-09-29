import SwiftUI

struct DSCardLogo: View {
    let imageName: String?
    var maxHeight: CGFloat = 16

    var body: some View {
        Group {
            if let imageName {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
            } else {
                Image(systemName: "creditcard")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxHeight: maxHeight)
        .clipShape(RoundedRectangle(cornerRadius: 3, style: .continuous))
        .accessibilityHidden(true)
    }
}

#Preview {
    HStack(alignment: .center, spacing: 12) {
        DSCardLogo(imageName: "logo_visa_premier")
        DSCardLogo(imageName: "logo_visa_classic")
        DSCardLogo(imageName: nil)
    }
    .padding()
}
