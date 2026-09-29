import Foundation

enum EuroFormat {
    static func string(from amount: Decimal?) -> String {
        guard let amount else { return "" }
        return amount.formatted(.currency(code: "EUR").locale(Locale(identifier: "fr_FR")))
    }

    static func displayString(from amount: Decimal?, masked: Bool) -> String {
        let formatted = string(from: amount)
        guard masked, formatted.isEmpty == false else { return formatted }
        return String(formatted.map { character in
            character.isNumber ? "•" : character
        })
    }
}
