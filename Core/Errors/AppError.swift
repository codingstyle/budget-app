import Foundation

enum AppError: LocalizedError {
    case persistenceUnavailable
    case householdMissing
    case importFailed(String)
    case invalidSpreadsheet
    case accountNotFound(lastFour: String)
    case sharingUnavailable
    case sharingFailed(String)

    var errorDescription: String? {
        switch self {
        case .persistenceUnavailable:
            "La base locale n’a pas pu être ouverte."
        case .householdMissing:
            "Aucun foyer n’est disponible."
        case .importFailed(let message):
            message
        case .invalidSpreadsheet:
            "Le fichier Excel n’est pas un relevé BNP Paribas ou Crédit Agricole reconnu."
        case .accountNotFound(let lastFour):
            "Aucun compte ne correspond aux chiffres \(lastFour)."
        case .sharingUnavailable:
            "Le partage iCloud n’est pas disponible sur cet appareil."
        case .sharingFailed(let message):
            message
        }
    }
}
