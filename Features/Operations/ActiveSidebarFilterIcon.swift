import SwiftUI

struct ActiveSidebarFilterIcon: View {
    let filter: ActiveSidebarFilter

    var body: some View {
        switch filter {
        case .account(let account):
            DSBankLogo(imageName: BankBrand.resolved(from: account.bank)?.imageName, size: 20)
        case .card(let card):
            DSCardLogo(imageName: card.type.imageName, maxHeight: 16)
        case .tag(let tag):
            DSTagGlyph(symbolName: tag.symbolName, colorHex: tag.colorHex)
        case .enseigne(let enseigne):
            DSEnseigneLogo(imageData: enseigne.logoData, size: 20)
        }
    }
}
