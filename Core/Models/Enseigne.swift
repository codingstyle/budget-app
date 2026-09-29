import Foundation
import SwiftData

@Model
final class Enseigne: Identifiable {
    var name: String = ""
    var normalizedName: String = ""
    @Attribute(.externalStorage)
    var logoData: Data?
    var household: Household?
    @Relationship(deleteRule: .nullify, inverse: \Operation.enseigne)
    var operations: [Operation]?
    var rules: [LabelRule]?

    init(
        name: String = "",
        household: Household? = nil
    ) {
        self.name = name
        self.normalizedName = LabelNormalizer.normalize(name)
        self.household = household
        self.operations = []
        self.rules = []
    }
}
