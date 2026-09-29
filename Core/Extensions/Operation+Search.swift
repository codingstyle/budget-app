import Foundation

extension Operation {
    func matchesSearch(_ query: String) -> Bool {
        let needle = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard needle.isEmpty == false else { return true }

        let fields = [
            originalLabel,
            displayLabel,
            merchant,
            place,
            motif,
            emetteur,
            transferReference,
            enseigne?.name ?? "",
        ]
        if fields.contains(where: { $0.localizedStandardContains(needle) }) {
            return true
        }
        return tags?.contains { $0.label.localizedStandardContains(needle) } == true
    }
}
