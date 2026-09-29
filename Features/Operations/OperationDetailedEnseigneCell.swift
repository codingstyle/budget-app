import SwiftData
import SwiftUI

struct OperationDetailedEnseigneCell: View {
    let operation: Operation
    let onEdit: (Enseigne) -> Void

    var body: some View {
        Button {
            if let enseigne = operation.enseigne {
                onEdit(enseigne)
            }
        } label: {
            HStack(alignment: .center, spacing: SpacingTokens.sm) {
                DSEnseigneLogo(imageData: operation.enseigne?.logoData, size: 28)
                VStack(alignment: .leading, spacing: 2) {
                    Text(operation.enseigne?.name ?? operation.merchant)
                        .textCase(.uppercase)
                        .lineLimit(1)
                    if place.isEmpty == false {
                        Text(place)
                            .font(.caption)
                            .foregroundStyle(ColorTokens.secondaryText)
                            .lineLimit(1)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .buttonStyle(.plain)
        .disabled(operation.enseigne == nil)
        .help(operation.enseigne == nil ? "" : "Modifier l’enseigne")
    }

    private var place: String {
        operation.place.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
