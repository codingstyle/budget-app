import SwiftData
import SwiftUI

struct OperationTypeCell: View {
    let operation: Operation

    var body: some View {
        Label(operation.paymentType.title, systemImage: operation.paymentType.symbolName)
            .labelStyle(.titleAndIcon)
            .lineLimit(1)
            .help(operation.paymentType.title)
            .accessibilityLabel(operation.paymentType.title)
    }
}
