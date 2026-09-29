import SwiftUI

struct DSEnseigneLogo: View {
    let imageData: Data?
    var size: CGFloat = 16

    var body: some View {
        Group {
            if let imageData, let image = Image(data: imageData) {
                image
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "storefront")
                    .resizable()
                    .scaledToFit()
                    .padding(size * 0.12)
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
        DSEnseigneLogo(imageData: nil, size: 16)
        DSEnseigneLogo(imageData: nil, size: 64)
    }
    .padding()
}
