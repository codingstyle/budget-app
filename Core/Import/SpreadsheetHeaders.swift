import Foundation

enum SpreadsheetHeaders {
    static func normalized(_ row: [Int: String]) -> [String: Int] {
        var result: [String: Int] = [:]
        for (column, title) in row {
            result[normalize(title)] = column
        }
        return result
    }

    static func normalize(_ title: String) -> String {
        title
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "fr_FR"))
            .filter(\.isLetter)
            .lowercased()
    }
}
