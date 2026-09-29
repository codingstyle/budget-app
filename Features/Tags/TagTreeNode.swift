import Foundation
import SwiftData

struct TagTreeNode: Identifiable {
    let tag: Tag
    let children: [TagTreeNode]?

    var id: PersistentIdentifier { tag.persistentModelID }

    static func roots(from tags: [Tag], filter: String) -> [TagTreeNode] {
        tags
            .filter { $0.parent == nil }
            .sorted { $0.label.localizedStandardCompare($1.label) == .orderedAscending }
            .compactMap { node(for: $0, filter: filter) }
    }

    private static func node(for tag: Tag, filter: String) -> TagTreeNode? {
        let needle = filter.trimmingCharacters(in: .whitespacesAndNewlines)
        let childNodes = tag.sortedChildren.compactMap { node(for: $0, filter: needle) }
        if needle.isEmpty == false,
           tag.label.localizedStandardContains(needle) == false,
           childNodes.isEmpty {
            return nil
        }
        return TagTreeNode(tag: tag, children: childNodes.isEmpty ? nil : childNodes)
    }
}
