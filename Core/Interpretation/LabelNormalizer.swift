import Foundation

enum LabelNormalizer {
    static func normalize(_ text: String) -> String {
        text
            .uppercased()
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func learningKey(from originalLabel: String) -> String {
        var key = normalize(originalLabel)
        key = key.replacingOccurrences(
            of: #"DU\s+(?:\d{2}[/-]\d{2}[/-]\d{2,4}|\d{6})(?:\s+\d{1,2}H\d{2})?(?:\s+A\s+[^-]+)?"#,
            with: "",
            options: .regularExpression
        )
        key = key.replacingOccurrences(
            of: #"\b\d{2}/\d{2}/\d{2}\b"#,
            with: "",
            options: .regularExpression
        )
        key = key.replacingOccurrences(
            of: #"CARTE\s+\d{4}X{8}\d{4}(?:\s+[A-Z]{3})?(?:\s+\d+[.,]\d{2}\s*EUR)?"#,
            with: "",
            options: .regularExpression
        )
        key = key.replacingOccurrences(
            of: #"CARTE\*?\s*\d{4}"#,
            with: "",
            options: .regularExpression
        )
        key = key.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        return key.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
