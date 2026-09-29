import Foundation

struct CatalogTransferPayload: Codable {
    var version: Int
    var tags: [TagRecord]
    var enseignes: [EnseigneRecord]
    var rules: [RuleRecord]

    struct TagRecord: Codable {
        var label: String
        var colorHex: String
        var symbolName: String
        var parentPath: String?
    }

    struct EnseigneRecord: Codable {
        var name: String
        var logoPNG: Data?
        var logoFormat: String
    }

    struct RuleRecord: Codable {
        var matchTexts: [String]
        var enseigneName: String?
        var tagPaths: [String]
    }
}
