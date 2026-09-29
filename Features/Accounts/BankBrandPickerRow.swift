import SwiftUI

struct BankBrandPickerRow: View {
    let brand: BankBrand

    var body: some View {
        Label {
            Text(brand.rawValue)
        } icon: {
            DSBankLogo(imageName: brand.imageName)
        }
    }
}
