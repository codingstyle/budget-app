import SwiftUI

struct OperationDateCell: View {
    let date: Date

    var body: some View {
        Text(date, format: FrenchDateFormat.style(for: date))
            .monospacedDigit()
    }
}
