import SwiftUI

struct BankBrandPicker: View {
    @Binding var selection: BankBrand

    var body: some View {
        Picker("Banque", selection: $selection) {
            ForEach(BankBrand.allCases) { brand in
                BankBrandPickerRow(brand: brand)
                    .tag(brand)
            }
        }
    }
}

#Preview {
    BankBrandPicker(selection: .constant(.bnpParibas))
        .padding()
}
