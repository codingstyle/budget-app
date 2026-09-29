import SwiftData
import SwiftUI

struct RuleTagTreePicker: View {
    let tags: [Tag]
    let selectedIDs: Set<PersistentIdentifier>
    let onToggle: (Tag) -> Void

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 2) {
                ForEach(nodes) { node in
                    RuleTagTreeOutline(node: node, selectedIDs: selectedIDs, onToggle: onToggle)
                }
            }
        }
        .frame(minHeight: 160, maxHeight: 280)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Étiquettes")
    }

    private var nodes: [TagTreeNode] {
        TagTreeNode.roots(from: tags, filter: "")
    }
}
