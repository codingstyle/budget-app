import Foundation

enum CardType: String, CaseIterable, Identifiable, Sendable {
    case visaClassic = "Visa Classic"
    case visaPremier = "Visa Premier"

    var id: String { rawValue }

    var imageName: String {
        switch self {
        case .visaClassic: "logo_visa_classic"
        case .visaPremier: "logo_visa_premier"
        }
    }

    static func resolved(from raw: String) -> CardType? {
        allCases.first { $0.rawValue.caseInsensitiveCompare(raw) == .orderedSame }
    }
}
