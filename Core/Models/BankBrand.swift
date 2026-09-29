import Foundation

enum BankBrand: String, CaseIterable, Identifiable, Sendable {
    case bnpParibas = "BNP Paribas"
    case creditAgricole = "Crédit Agricole"

    var id: String { rawValue }

    var imageName: String {
        switch self {
        case .bnpParibas: "logo_bnp_paribas"
        case .creditAgricole: "logo_credit_agricole"
        }
    }

    static func resolved(from raw: String) -> BankBrand? {
        let normalized = raw
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "fr_FR"))
            .lowercased()
        if normalized.contains("bnp") || normalized.contains("paribas") {
            return .bnpParibas
        }
        if normalized.contains("agricole") || normalized == "ca" || normalized.contains("credit agricole") {
            return .creditAgricole
        }
        return allCases.first { $0.rawValue.caseInsensitiveCompare(raw) == .orderedSame }
    }
}
