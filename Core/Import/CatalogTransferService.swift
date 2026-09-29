import Foundation
import SwiftData

enum CatalogTransferService {
    static let catalogFileName = "catalog.plist"

    @MainActor
    static func exportArchive(from household: Household, in context: ModelContext) throws -> Data {
        let payload = CatalogTransferPayload(
            version: 1,
            tags: tagRecords(in: household, context: context),
            enseignes: enseigneRecords(in: household, context: context),
            rules: ruleRecords(in: household, context: context)
        )
        let plist = try PropertyListEncoder().encode(payload)
        return try ZipWriter.archive(entries: [catalogFileName: plist])
    }

    @MainActor
    static func importArchive(_ archive: Data, into household: Household, in context: ModelContext) throws {
        let plist = try catalogData(in: archive)
        let payload = try PropertyListDecoder().decode(CatalogTransferPayload.self, from: plist)
        importTags(payload.tags, into: household, in: context)
        importEnseignes(payload.enseignes, into: household, in: context)
        importRules(payload.rules, into: household, in: context)
        try context.save()
    }

    @MainActor
    private static func tagRecords(in household: Household, context: ModelContext) -> [CatalogTransferPayload.TagRecord] {
        orderedTags(in: household, context: context).map { tag in
            CatalogTransferPayload.TagRecord(
                label: tag.label,
                colorHex: tag.colorHex,
                symbolName: tag.symbolName,
                parentPath: tag.parent?.hierarchicalLabel
            )
        }
    }

    @MainActor
    private static func enseigneRecords(in household: Household, context: ModelContext) -> [CatalogTransferPayload.EnseigneRecord] {
        householdEnseignes(household, in: context)
            .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
            .map { enseigne in
                CatalogTransferPayload.EnseigneRecord(
                    name: enseigne.name,
                    logoPNG: pngLogo(from: enseigne.logoData),
                    logoFormat: "png"
                )
            }
    }

    @MainActor
    private static func ruleRecords(in household: Household, context: ModelContext) -> [CatalogTransferPayload.RuleRecord] {
        householdRules(household, in: context).map { rule in
            CatalogTransferPayload.RuleRecord(
                matchTexts: rule.matchTexts,
                enseigneName: rule.enseigne?.name,
                tagPaths: (rule.tags ?? []).map(\.hierarchicalLabel).sorted {
                    $0.localizedStandardCompare($1) == .orderedAscending
                }
            )
        }
    }

    @MainActor
    private static func importTags(
        _ records: [CatalogTransferPayload.TagRecord],
        into household: Household,
        in context: ModelContext
    ) {
        var existing = allTags(in: household, context: context)
        for record in records {
            let path = hierarchicalPath(label: record.label, parentPath: record.parentPath)
            if existing.contains(where: { matches($0.hierarchicalLabel, path) }) {
                continue
            }
            let parent = record.parentPath.flatMap { parentPath in
                existing.first { matches($0.hierarchicalLabel, parentPath) }
            }
            let tag = Tag(
                label: record.label,
                colorHex: record.colorHex,
                symbolName: record.symbolName,
                household: household,
                parent: parent
            )
            context.insert(tag)
            existing.append(tag)
        }
    }

    @MainActor
    private static func importEnseignes(
        _ records: [CatalogTransferPayload.EnseigneRecord],
        into household: Household,
        in context: ModelContext
    ) {
        for record in records {
            let key = LabelNormalizer.normalize(record.name)
            if householdEnseignes(household, in: context).contains(where: { $0.normalizedName == key }) {
                continue
            }
            let enseigne = Enseigne(name: record.name, household: household)
            enseigne.logoData = record.logoPNG
            context.insert(enseigne)
        }
    }

    @MainActor
    private static func importRules(
        _ records: [CatalogTransferPayload.RuleRecord],
        into household: Household,
        in context: ModelContext
    ) {
        let tags = allTags(in: household, context: context)
        let enseignes = householdEnseignes(household, in: context)
        var existingRules = householdRules(household, in: context)
        for record in records {
            if existingRules.contains(where: { matches($0, record) }) {
                continue
            }
            let rule = LabelRule(matchTexts: record.matchTexts, household: household)
            if let enseigneName = record.enseigneName {
                let key = LabelNormalizer.normalize(enseigneName)
                rule.enseigne = enseignes.first { $0.normalizedName == key }
            }
            rule.tags = record.tagPaths.compactMap { path in
                tags.first { matches($0.hierarchicalLabel, path) }
            }
            context.insert(rule)
            existingRules.append(rule)
        }
    }

    @MainActor
    private static func matches(_ rule: LabelRule, _ record: CatalogTransferPayload.RuleRecord) -> Bool {
        let existingTexts = Set(rule.matchTexts.map { $0.localizedLowercase })
        let incomingTexts = Set(record.matchTexts.map { $0.localizedLowercase })
        guard existingTexts == incomingTexts else { return false }
        let existingEnseigne = rule.enseigne.map { LabelNormalizer.normalize($0.name) } ?? ""
        let incomingEnseigne = record.enseigneName.map(LabelNormalizer.normalize) ?? ""
        guard existingEnseigne == incomingEnseigne else { return false }
        let existingTags = Set((rule.tags ?? []).map { $0.hierarchicalLabel.localizedLowercase })
        let incomingTags = Set(record.tagPaths.map(\.localizedLowercase))
        return existingTags == incomingTags
    }

    @MainActor
    private static func orderedTags(in household: Household, context: ModelContext) -> [Tag] {
        let roots = allTags(in: household, context: context)
            .filter { $0.parent == nil }
            .sorted { $0.label.localizedStandardCompare($1.label) == .orderedAscending }
        var result: [Tag] = []
        func walk(_ tag: Tag) {
            result.append(tag)
            for child in tag.sortedChildren {
                walk(child)
            }
        }
        roots.forEach(walk)
        return result
    }

    @MainActor
    private static func allTags(in household: Household, context: ModelContext) -> [Tag] {
        let tags = (try? context.fetch(FetchDescriptor<Tag>())) ?? []
        return tags.filter { $0.household?.persistentModelID == household.persistentModelID }
    }

    @MainActor
    private static func householdEnseignes(_ household: Household, in context: ModelContext) -> [Enseigne] {
        let enseignes = (try? context.fetch(FetchDescriptor<Enseigne>())) ?? []
        return enseignes.filter { $0.household?.persistentModelID == household.persistentModelID }
    }

    @MainActor
    private static func householdRules(_ household: Household, in context: ModelContext) -> [LabelRule] {
        let rules = (try? context.fetch(FetchDescriptor<LabelRule>())) ?? []
        return rules.filter { $0.household?.persistentModelID == household.persistentModelID }
    }

    private static func hierarchicalPath(label: String, parentPath: String?) -> String {
        if let parentPath, parentPath.isEmpty == false {
            return "\(parentPath) / \(label)"
        }
        return label
    }

    private static func matches(_ lhs: String, _ rhs: String) -> Bool {
        lhs.localizedCaseInsensitiveCompare(rhs) == .orderedSame
    }

    private static func pngLogo(from data: Data?) -> Data? {
        guard let data, data.isEmpty == false else { return nil }
        if isPNG(data) {
            return data
        }
        return ImageResizer.pngData(from: data)
    }

    private static func isPNG(_ data: Data) -> Bool {
        data.starts(with: [0x89, 0x50, 0x4E, 0x47])
    }

    private static func catalogData(in archive: Data) throws -> Data {
        if let data = try? ZipArchive.data(named: catalogFileName, in: archive) {
            return data
        }
        let entries = try ZipArchive.entries(in: archive)
        guard let plist = entries.first(where: { $0.name.hasSuffix(".plist") }) else {
            throw AppError.importFailed("Aucun fichier catalog.plist dans l’archive.")
        }
        return try ZipArchive.data(named: plist.name, in: archive)
    }
}
