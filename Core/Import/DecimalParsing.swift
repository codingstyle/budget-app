import Foundation

enum DecimalParsing {
    static func parse(_ raw: String) -> Decimal? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else { return nil }

        let withoutCurrency = trimmed
            .replacingOccurrences(of: "€", with: "")
            .replacingOccurrences(of: "EUR", with: "", options: .caseInsensitive)
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let negative = withoutCurrency.hasPrefix("-") || withoutCurrency.hasSuffix("-")
        let unsigned = withoutCurrency
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "\u{00A0}", with: "")
            .replacingOccurrences(of: " ", with: "")

        var normalized = unsigned
        if unsigned.contains(",") && unsigned.contains(".") {
            if let lastComma = unsigned.lastIndex(of: ","),
               let lastDot = unsigned.lastIndex(of: "."),
               lastComma > lastDot {
                normalized = unsigned.replacingOccurrences(of: ".", with: "")
                    .replacingOccurrences(of: ",", with: ".")
            } else {
                normalized = unsigned.replacingOccurrences(of: ",", with: "")
            }
        } else if unsigned.contains(",") {
            normalized = unsigned.replacingOccurrences(of: ",", with: ".")
        }

        guard let value = Decimal(string: normalized, locale: Locale(identifier: "en_US_POSIX")) else {
            return nil
        }
        return negative ? -value : value
    }
}
