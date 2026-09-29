import SwiftData
import SwiftUI

struct OperationsTagMenu: View {
    let tags: [Tag]
    let onSelect: (Tag) -> Void
    let onCreate: () -> Void

    var body: some View {
        ForEach(sortedTags) { tag in
            Button(tag.hierarchicalLabel) {
                onSelect(tag)
            }
        }
        if tags.isEmpty == false {
            Divider()
        }
        Button("Nouvelle étiquette…", systemImage: "plus", action: onCreate)
    }

    private var sortedTags: [Tag] {
        tags.sorted { $0.hierarchicalLabel.localizedStandardCompare($1.hierarchicalLabel) == .orderedAscending }
    }
}
