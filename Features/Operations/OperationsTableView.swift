import SwiftData
import SwiftUI

struct OperationsTableView: View {
    let operations: [Operation]
    let tags: [Tag]
    @Binding var selection: Set<PersistentIdentifier>
    let onApplyTag: (Tag) -> Void
    let onCreateTag: () -> Void
    let onCreateRule: (Operation) -> Void
    let onAssociateRefund: (Operation) -> Void
    let onUnlinkRefund: (Operation) -> Void

    @State private var enseigneBeingEdited: Enseigne?

    var body: some View {
        detailedTable
            .contextMenu(forSelectionType: PersistentIdentifier.self) { selectedIDs in
                if selectedIDs.isEmpty == false {
                    Menu("Ajouter une étiquette", systemImage: "tag") {
                        OperationsTagMenu(tags: tags, onSelect: onApplyTag, onCreate: onCreateTag)
                    }
                }
                if let operation = singleOperation(in: selectedIDs) {
                    Button("Créer une règle", systemImage: "text.badge.plus") {
                        onCreateRule(operation)
                    }
                    if operation.isCredit && operation.refundOf == nil {
                        Button("Associer un remboursement…", systemImage: "arrow.turn.down.right") {
                            onAssociateRefund(operation)
                        }
                    }
                    if operation.isLinkedRefund {
                        Button("Dissocier le remboursement", systemImage: "xmark") {
                            onUnlinkRefund(operation)
                        }
                    }
                }
            }
            .sheet(item: $enseigneBeingEdited) { enseigne in
                EnseigneEditorView(enseigne: enseigne)
            }
    }

    private var detailedTable: some View {
        Table(operations, selection: $selection) {
            TableColumn("Date d’effet") { operation in
                OperationEffectDateCell(operation: operation)
            }
            .width(100)

            TableColumn("Type d’opération") { operation in
                OperationTypeCell(operation: operation)
            }
            .width(168)

            TableColumn("Enseigne") { operation in
                OperationDetailedEnseigneCell(operation: operation, onEdit: { enseigneBeingEdited = $0 })
            }
            .width(min: 200, ideal: 280)

            TableColumn("Étiquettes") { operation in
                OperationTagsCell(operation: operation)
            }
            .width(min: 140, ideal: 200)

            TableColumn("Débit") { operation in
                DSMoneyText(amount: operation.debit, isCredit: false)
            }
            .width(90)

            TableColumn("Crédit") { operation in
                DSMoneyText(amount: operation.credit, isCredit: true)
            }
            .width(90)
        }
    }

    private func singleOperation(in selectedIDs: Set<PersistentIdentifier>) -> Operation? {
        guard selectedIDs.count == 1, let id = selectedIDs.first else { return nil }
        return operations.first { $0.persistentModelID == id }
    }
}
