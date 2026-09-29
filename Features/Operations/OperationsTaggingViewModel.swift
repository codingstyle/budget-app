import SwiftData
import SwiftUI

@MainActor
@Observable
final class OperationsTaggingViewModel {
    func apply(_ tag: Tag, to operations: [Operation], in context: ModelContext) {
        for operation in operations {
            var assigned = operation.tags ?? []
            guard assigned.contains(where: { $0.persistentModelID == tag.persistentModelID }) == false else {
                continue
            }
            assigned.append(tag)
            operation.tags = assigned
        }
        try? context.save()
    }
}
