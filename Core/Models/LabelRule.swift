import Foundation
import SwiftData

@Model
final class LabelRule {
    var normalizedKey: String = ""
    var paymentTypeRaw: String = PaymentType.unknown.rawValue
    var merchant: String = ""
    var displayLabel: String = ""
    var motif: String = ""
    var reference: String = ""
    var matchText: String = ""
    var matchTextsRaw: String = ""
    var household: Household?
    @Relationship(deleteRule: .nullify, inverse: \Enseigne.rules)
    var enseigne: Enseigne?
    @Relationship(deleteRule: .nullify, inverse: \Tag.rules)
    var tags: [Tag]?

    init(
        normalizedKey: String = "",
        paymentType: PaymentType = .unknown,
        merchant: String = "",
        displayLabel: String = "",
        motif: String = "",
        reference: String = "",
        matchText: String = "",
        matchTexts: [String] = [],
        household: Household? = nil
    ) {
        self.normalizedKey = normalizedKey
        self.paymentTypeRaw = paymentType.rawValue
        self.merchant = merchant
        self.displayLabel = displayLabel
        self.motif = motif
        self.reference = reference
        self.household = household
        self.enseigne = nil
        self.tags = []
        let needles = Self.cleaned(matchTexts.isEmpty ? [matchText] : matchTexts)
        self.matchText = needles.first ?? ""
        self.matchTextsRaw = Self.encode(needles)
    }

    var matchTexts: [String] {
        get {
            let decoded = Self.decode(matchTextsRaw)
            if decoded.isEmpty == false {
                return decoded
            }
            let legacy = matchText.trimmingCharacters(in: .whitespacesAndNewlines)
            return legacy.isEmpty ? [] : [legacy]
        }
        set {
            let needles = Self.cleaned(newValue)
            matchText = needles.first ?? ""
            matchTextsRaw = Self.encode(needles)
        }
    }

    private static func cleaned(_ values: [String]) -> [String] {
        values
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.isEmpty == false }
    }

    private static func encode(_ values: [String]) -> String {
        guard let data = try? JSONEncoder().encode(values) else { return "" }
        return String(data: data, encoding: .utf8) ?? ""
    }

    private static func decode(_ raw: String) -> [String] {
        guard raw.isEmpty == false, let data = raw.data(using: .utf8) else { return [] }
        return (try? JSONDecoder().decode([String].self, from: data)) ?? []
    }

    var paymentType: PaymentType {
        get { PaymentType(rawValue: paymentTypeRaw) ?? .unknown }
        set { paymentTypeRaw = newValue.rawValue }
    }
}
