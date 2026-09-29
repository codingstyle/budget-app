import SwiftData
import SwiftUI

struct RuleTagTreeOutline: View {
    let node: TagTreeNode
    let selectedIDs: Set<PersistentIdentifier>
    let onToggle: (Tag) -> Void
    @State private var isExpanded = true

    var body: some View {
        if let children = node.children, children.isEmpty == false {
            DisclosureGroup(isExpanded: $isExpanded) {
                ForEach(children) { child in
                    RuleTagTreeOutline(node: child, selectedIDs: selectedIDs, onToggle: onToggle)
                }
                .padding(.leading, SpacingTokens.lg)
            } label: {
                RuleTagTreeRow(
                    tag: node.tag,
                    isSelected: selectedIDs.contains(node.tag.persistentModelID),
                    onToggle: onToggle
                )
            }
        } else {
            RuleTagTreeRow(
                tag: node.tag,
                isSelected: selectedIDs.contains(node.tag.persistentModelID),
                onToggle: onToggle
            )
        }
    }
}
