import Foundation

extension Tag {
    func matchesSidebarFilter(_ query: String) -> Bool {
        let needle = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard needle.isEmpty == false else { return true }
        if label.localizedStandardContains(needle) {
            return true
        }
        return sortedChildren.contains { $0.matchesSidebarFilter(needle) }
    }
}
