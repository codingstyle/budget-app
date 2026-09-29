import Foundation

enum SFSymbolCatalog {
    static let names: [String] = loadNames()

    private static func loadNames() -> [String] {
        let urls = [
            URL(fileURLWithPath: "/System/Library/CoreServices/CoreGlyphs.bundle/Contents/Resources/name_availability.plist"),
            URL(fileURLWithPath: "/System/Library/PrivateFrameworks/SFSymbols.framework/Versions/A/Resources/CoreGlyphs.bundle/Contents/Resources/name_availability.plist"),
        ]
        guard let url = urls.first(where: { FileManager.default.fileExists(atPath: $0.path) }),
              let data = try? Data(contentsOf: url),
              let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
              let symbols = plist["symbols"] as? [String: String] else {
            return fallbackNames
        }

        let yearToRelease = plist["year_to_release"] as? [String: [String: String]] ?? [:]
        return symbols
            .compactMap { name, year in
                isAvailable(year: year, yearToRelease: yearToRelease) ? name : nil
            }
            .sorted { $0.localizedStandardCompare($1) == .orderedAscending }
    }

    private static func isAvailable(year: String, yearToRelease: [String: [String: String]]) -> Bool {
        guard let macOSVersion = yearToRelease[year]?["macOS"] else { return true }
        let required = macOSVersion.split(separator: ".").compactMap { Int($0) }
        let current = ProcessInfo.processInfo.operatingSystemVersion
        let actual = [current.majorVersion, current.minorVersion, current.patchVersion]
        for index in 0..<max(required.count, actual.count) {
            let lhs = index < actual.count ? actual[index] : 0
            let rhs = index < required.count ? required[index] : 0
            if lhs != rhs {
                return lhs > rhs
            }
        }
        return true
    }

    private static let fallbackNames = [
        "tag", "cart", "house", "car", "fork.knife", "heart", "airplane",
        "tram", "bolt", "phone", "gift", "bag", "creditcard", "leaf",
        "book", "gamecontroller", "music.note", "stethoscope", "wrench",
    ]
}
