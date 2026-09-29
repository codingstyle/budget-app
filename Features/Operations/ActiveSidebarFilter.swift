import SwiftData

enum ActiveSidebarFilter: Identifiable {
    case account(BankAccount)
    case card(Card)
    case tag(Tag)
    case enseigne(Enseigne)

    var id: String {
        switch self {
        case .account(let account):
            "account-\(account.persistentModelID)"
        case .card(let card):
            "card-\(card.persistentModelID)"
        case .tag(let tag):
            "tag-\(tag.persistentModelID)"
        case .enseigne(let enseigne):
            "enseigne-\(enseigne.persistentModelID)"
        }
    }

    var category: String {
        switch self {
        case .account: "Compte"
        case .card: "Carte"
        case .tag: "Étiquette"
        case .enseigne: "Enseigne"
        }
    }

    var title: String {
        switch self {
        case .account(let account):
            account.label
        case .card(let card):
            card.cardholderName
        case .tag(let tag):
            tag.label
        case .enseigne(let enseigne):
            enseigne.name
        }
    }

    var canClear: Bool {
        switch self {
        case .account: false
        case .card, .tag, .enseigne: true
        }
    }
}
