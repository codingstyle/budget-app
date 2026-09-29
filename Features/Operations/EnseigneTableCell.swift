import SwiftData
import SwiftUI

struct EnseigneTableCell: View {
    let operation: Operation
    let onEdit: (Enseigne) -> Void

    var body: some View {
        Button {
            if let enseigne = operation.enseigne {
                onEdit(enseigne)
            }
        } label: {
            HStack(spacing: SpacingTokens.sm) {
                DSEnseigneLogo(imageData: operation.enseigne?.logoData, size: 16)
                Text(operation.enseigne?.name ?? operation.merchant)
                    .textCase(.uppercase)
                    .lineLimit(1)
            }
        }
        .buttonStyle(.plain)
        .disabled(operation.enseigne == nil)
        .help("Modifier l’enseigne")
    }
}
