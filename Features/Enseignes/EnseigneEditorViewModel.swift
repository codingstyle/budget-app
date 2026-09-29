import SwiftData
import SwiftUI

@MainActor
@Observable
final class EnseigneEditorViewModel {
    var name: String
    var logoPreview: Data?
    var errorMessage: String?
    var isImporterPresented = false

    private let enseigne: Enseigne?
    private let household: Household?

    var isCreating: Bool { enseigne == nil }

    init(enseigne: Enseigne? = nil, household: Household? = nil) {
        self.enseigne = enseigne
        self.household = household ?? enseigne?.household
        self.name = enseigne?.name ?? ""
        self.logoPreview = enseigne?.logoData
    }

    func importLogo(from url: URL) {
        errorMessage = nil
        let accessed = url.startAccessingSecurityScopedResource()
        defer {
            if accessed {
                url.stopAccessingSecurityScopedResource()
            }
        }
        do {
            let original = try Data(contentsOf: url)
            guard let resized = ImageResizer.pngData(from: original, maxPixelSize: 128) else {
                errorMessage = "Ce fichier image n’a pas pu être lu."
                return
            }
            logoPreview = resized
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func removeLogo() {
        logoPreview = nil
    }

    func save(in context: ModelContext) -> Enseigne? {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else {
            errorMessage = "Le nom de l’enseigne est obligatoire."
            return nil
        }

        let owner = household ?? HouseholdBootstrap.loadOrCreate(in: context)
        let key = LabelNormalizer.normalize(trimmed)
        if let duplicate = existing(matching: key, household: owner, excluding: enseigne, in: context) {
            errorMessage = "L’enseigne « \(duplicate.name) » existe déjà."
            return nil
        }

        let target: Enseigne
        if let enseigne {
            target = enseigne
        } else {
            target = Enseigne(name: trimmed, household: owner)
            context.insert(target)
        }

        target.name = trimmed
        target.normalizedName = key
        target.logoData = logoPreview
        for operation in target.operations ?? [] {
            operation.merchant = trimmed
        }

        do {
            try context.save()
            return target
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }

    private func existing(
        matching key: String,
        household: Household,
        excluding: Enseigne?,
        in context: ModelContext
    ) -> Enseigne? {
        let enseignes = (try? context.fetch(FetchDescriptor<Enseigne>())) ?? []
        return enseignes.first { candidate in
            guard candidate.normalizedName == key else { return false }
            guard candidate.household?.persistentModelID == household.persistentModelID else { return false }
            return candidate.persistentModelID != excluding?.persistentModelID
        }
    }
}
