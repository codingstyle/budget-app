import Foundation

struct SpreadsheetCell: Sendable {
    let row: Int
    let column: Int
    let value: String
}

enum ColumnReference {
    static func index(from reference: String) -> Int? {
        let letters = reference.prefix { $0.isLetter }
        guard letters.isEmpty == false else { return nil }
        var result = 0
        for character in letters.uppercased() {
            guard let ascii = character.asciiValue else { return nil }
            result = result * 26 + Int(ascii - 64)
        }
        return result
    }

    static func row(from reference: String) -> Int? {
        let digits = reference.drop { $0.isLetter }
        return Int(digits)
    }
}
