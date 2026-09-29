import SwiftUI

struct DebugCommands: Commands {
    @FocusedValue(\.accountDebugHandler) private var handler

    var body: some Commands {
        CommandMenu("Debug") {
            Button("Vider les opérations", action: clearOperations)
                .disabled(handler?.canDebugSelectedAccount != true)
            Button("Vider les tags du compte", action: clearTags)
                .disabled(handler?.canDebugSelectedAccount != true)
            Button("Vider les enseignes", action: clearEnseignes)
                .disabled(handler?.canDebugSelectedAccount != true)
            Divider()
            Button("Exporter le catalogue…", action: exportCatalog)
                .disabled(handler?.canDebugSelectedAccount != true)
            Button("Importer un catalogue…", action: importCatalog)
                .disabled(handler?.canDebugSelectedAccount != true)
        }
    }

    private func clearOperations() {
        handler?.clearOperations()
    }

    private func clearTags() {
        handler?.clearTags()
    }

    private func clearEnseignes() {
        handler?.clearEnseignes()
    }

    private func exportCatalog() {
        handler?.exportCatalog()
    }

    private func importCatalog() {
        handler?.importCatalog()
    }
}
