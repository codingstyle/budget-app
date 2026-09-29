import Foundation

enum SidebarSection: String, CaseIterable, Identifiable {
    case accounts
    case cards
    case tags
    case enseignes

    var id: Self { self }

    var title: String {
        switch self {
        case .accounts: "Comptes"
        case .cards: "Cartes"
        case .tags: "Étiquettes"
        case .enseignes: "Enseignes"
        }
    }

    var systemImage: String {
        switch self {
        case .accounts: "building.columns"
        case .cards: "creditcard"
        case .tags: "tag"
        case .enseignes: "storefront"
        }
    }

    var filterPrompt: String {
        switch self {
        case .accounts: "Filtrer les comptes"
        case .cards: "Filtrer les cartes"
        case .tags: "Filtrer les étiquettes"
        case .enseignes: "Filtrer les enseignes"
        }
    }

    var addLabel: String {
        switch self {
        case .accounts: "Ajouter un compte"
        case .cards: "Ajouter une carte"
        case .tags: "Ajouter une étiquette"
        case .enseignes: "Ajouter une enseigne"
        }
    }
}
