import Foundation

enum PaymentType: String, CaseIterable, Identifiable, Sendable {
    case cardPayment
    case atmWithdrawal
    case directDebit
    case instantTransferOut
    case instantTransferIn
    case transfer
    case bankFee
    case unknown

    var id: String { rawValue }

    var title: String {
        switch self {
        case .cardPayment: "Paiement CB"
        case .atmWithdrawal: "Retrait distributeur"
        case .directDebit: "Prélèvement"
        case .instantTransferOut: "Virement instantané émis"
        case .instantTransferIn: "Virement instantané reçu"
        case .transfer: "Virement"
        case .bankFee: "Commissions"
        case .unknown: "Autre"
        }
    }

    var isCardPayment: Bool { self == .cardPayment }
    var isDirectDebit: Bool { self == .directDebit }
    var isTransfer: Bool {
        self == .transfer || self == .instantTransferIn || self == .instantTransferOut
    }

    var symbolName: String {
        switch self {
        case .cardPayment: "creditcard"
        case .atmWithdrawal: "banknote"
        case .directDebit: "arrow.down.circle"
        case .instantTransferOut, .instantTransferIn, .transfer:
            "eurosign.arrow.trianglehead.counterclockwise.rotate.90"
        case .bankFee: "building.columns"
        case .unknown: "questionmark.circle"
        }
    }
}
