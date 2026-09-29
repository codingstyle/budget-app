import AppKit
import Foundation
import SwiftData
import UniformTypeIdentifiers

@MainActor
@Observable
final class AccountDebugHandler {
    var selectedAccountID: PersistentIdentifier?
    var session: AppSession?
    var modelContext: ModelContext?

    var canDebugSelectedAccount: Bool {
        selectedAccountID != nil && modelContext != nil
    }

    func clearOperations() {
        guard let context = modelContext, let account = selectedAccount(in: context) else { return }
        try? AccountDebugService.clearOperations(of: account, in: context)
    }

    func clearTags() {
        guard let context = modelContext, let account = selectedAccount(in: context) else { return }
        try? AccountDebugService.clearTags(of: account, in: context)
        session?.selectedTagID = nil
    }

    func clearEnseignes() {
        guard let context = modelContext, let account = selectedAccount(in: context) else { return }
        try? AccountDebugService.clearEnseignes(of: account, in: context)
    }

    func exportCatalog() {
        guard let context = modelContext, let household = selectedAccount(in: context)?.household else { return }
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.zip]
        panel.nameFieldStringValue = "budget-catalogue.zip"
        panel.canCreateDirectories = true
        guard panel.runModal() == .OK, let url = panel.url else { return }
        let accessed = url.startAccessingSecurityScopedResource()
        defer {
            if accessed {
                url.stopAccessingSecurityScopedResource()
            }
        }
        do {
            let archive = try CatalogTransferService.exportArchive(from: household, in: context)
            try archive.write(to: url)
            presentAlert(title: "Export", message: "Le catalogue a été exporté.")
        } catch {
            presentAlert(title: "Export", message: error.localizedDescription)
        }
    }

    func importCatalog() {
        guard let context = modelContext, let household = selectedAccount(in: context)?.household else { return }
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.zip]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        guard panel.runModal() == .OK, let url = panel.url else { return }
        let accessed = url.startAccessingSecurityScopedResource()
        defer {
            if accessed {
                url.stopAccessingSecurityScopedResource()
            }
        }
        do {
            let archive = try Data(contentsOf: url)
            try CatalogTransferService.importArchive(archive, into: household, in: context)
            presentAlert(title: "Import", message: "Le catalogue a été importé.")
        } catch {
            presentAlert(title: "Import", message: error.localizedDescription)
        }
    }

    private func selectedAccount(in context: ModelContext) -> BankAccount? {
        guard let selectedAccountID else { return nil }
        let accounts = (try? context.fetch(FetchDescriptor<BankAccount>())) ?? []
        return accounts.first { $0.persistentModelID == selectedAccountID }
    }

    private func presentAlert(title: String, message: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.runModal()
    }
}
