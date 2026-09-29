import SwiftData
import SwiftUI

@MainActor
@Observable
final class TagEditorViewModel {
    var label: String
    var colorHex: String
    var symbolName: String
    var parentID: PersistentIdentifier?
    var errorMessage: String?

    init(tag: Tag? = nil, parent: Tag? = nil) {
        self.label = tag?.label ?? ""
        self.colorHex = tag?.colorHex ?? parent?.colorHex ?? TailwindPalette.defaultHex
        self.symbolName = tag?.symbolName ?? parent?.symbolName ?? "tag"
        self.parentID = tag?.parent?.persistentModelID ?? parent?.persistentModelID
    }

    func save(
        tag: Tag?,
        household: Household,
        parent: Tag?,
        in context: ModelContext
    ) -> Tag? {
        let trimmed = label.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else {
            errorMessage = "Le libellé est obligatoire."
            return nil
        }

        let hex = colorHex.hasPrefix("#") ? colorHex : "#\(colorHex)"
        if let tag {
            tag.label = trimmed
            tag.colorHex = hex
            tag.symbolName = symbolName
            tag.parent = parent
            try? context.save()
            return tag
        }

        let created = Tag(
            label: trimmed,
            colorHex: hex,
            symbolName: symbolName,
            household: household,
            parent: parent
        )
        context.insert(created)
        try? context.save()
        return created
    }
}
