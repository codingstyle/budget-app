import Foundation
import SwiftData

@Model
final class Tag {
    var label: String = ""
    var colorHex: String = "#5B8DEF"
    var symbolName: String = "tag"
    var household: Household?
    var parent: Tag?
    @Relationship(deleteRule: .cascade, inverse: \Tag.parent)
    var children: [Tag]?
    var operations: [Operation]?
    var rules: [LabelRule]?

    init(
        label: String = "",
        colorHex: String = "#5B8DEF",
        symbolName: String = "tag",
        household: Household? = nil,
        parent: Tag? = nil
    ) {
        self.label = label
        self.colorHex = colorHex
        self.symbolName = symbolName
        self.household = household
        self.parent = parent
        self.children = []
        self.operations = []
        self.rules = []
    }

    var sortedChildren: [Tag] {
        (children ?? []).sorted { $0.label.localizedStandardCompare($1.label) == .orderedAscending }
    }

    var hierarchicalLabel: String {
        if let parent {
            return "\(parent.hierarchicalLabel) / \(label)"
        }
        return label
    }

    var descendantIDs: [PersistentIdentifier] {
        var ids = [persistentModelID]
        for child in sortedChildren {
            ids.append(contentsOf: child.descendantIDs)
        }
        return ids
    }
}
