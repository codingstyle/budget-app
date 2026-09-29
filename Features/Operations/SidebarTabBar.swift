import SwiftUI

struct SidebarTabBar: View {
    @Binding var selection: SidebarSection

    var body: some View {
        HStack(spacing: 2) {
            ForEach(SidebarSection.allCases) { section in
                Button {
                    selection = section
                } label: {
                    Image(systemName: section.systemImage)
                        .font(.body)
                        .frame(maxWidth: .infinity, minHeight: 26)
                        .foregroundStyle(selection == section ? Color.white : ColorTokens.secondaryText)
                        .background(
                            selection == section ? ColorTokens.accent : Color.clear,
                            in: RoundedRectangle(cornerRadius: 6, style: .continuous)
                        )
                }
                .buttonStyle(.plain)
                .help(section.title)
                .accessibilityLabel(section.title)
                .accessibilityAddTraits(selection == section ? .isSelected : [])
            }
        }
        .padding(3)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.primary.opacity(0.06))
        )
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.12))
        }
        .padding(.horizontal, SpacingTokens.sm)
        .padding(.vertical, SpacingTokens.sm)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Navigateur")
    }
}

#Preview {
    SidebarTabBar(selection: .constant(.accounts))
        .frame(width: 240)
        .padding()
}
