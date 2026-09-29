import SwiftUI

struct TagTreeBranchGuide: View {
    var body: some View {
        Capsule()
            .fill(Color(nsColor: .tertiaryLabelColor))
            .frame(width: 1.5)
            .frame(maxHeight: .infinity)
            .accessibilityHidden(true)
    }
}

#Preview {
    HStack(alignment: .top, spacing: SpacingTokens.sm) {
        TagTreeBranchGuide()
        VStack(alignment: .leading, spacing: SpacingTokens.xs) {
            DSTagChip(title: "Courses", symbolName: "cart", colorHex: "#5B8DEF", isCompact: true)
            DSTagChip(title: "Marché", symbolName: "leaf", colorHex: "#5B8DEF", isCompact: true)
        }
    }
    .padding()
}
