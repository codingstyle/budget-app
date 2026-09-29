import SwiftData
import SwiftUI

struct TagTreeOutline: View {
    let node: TagTreeNode
    let selectedID: PersistentIdentifier?
    let onSelect: (Tag) -> Void
    let onEdit: (Tag) -> Void
    let onAddChild: (Tag) -> Void
    @State private var isExpanded = true

    var body: some View {
        if let children = node.children, children.isEmpty == false {
            DisclosureGroup(isExpanded: $isExpanded) {
                ForEach(children) { child in
                    TagTreeOutline(
                        node: child,
                        selectedID: selectedID,
                        onSelect: onSelect,
                        onEdit: onEdit,
                        onAddChild: onAddChild
                    )
                }
                .padding(.leading, SpacingTokens.lg)
            } label: {
                TagTreeRow(
                    tag: node.tag,
                    isSelected: selectedID == node.tag.persistentModelID,
                    onSelect: onSelect,
                    onEdit: onEdit,
                    onAddChild: onAddChild
                )
            }
        } else {
            TagTreeRow(
                tag: node.tag,
                isSelected: selectedID == node.tag.persistentModelID,
                onSelect: onSelect,
                onEdit: onEdit,
                onAddChild: onAddChild
            )
        }
    }
}
