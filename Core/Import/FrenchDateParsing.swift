import Foundation

enum FrenchDateParsing {
    static func parse(_ raw: String) -> Date? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let dayMonthYear = dayMonthYear(from: trimmed) else { return nil }
        return makeDate(dayMonthYear, hour: 0, minute: 0, timeZone: FrenchDateFormat.timeZone)
    }

    static func parseLabelDate(token: String, hour: Int? = nil, minute: Int? = nil) -> Date? {
        guard let dayMonthYear = dayMonthYear(from: token) else { return nil }
        let resolvedHour = hour ?? 0
        let resolvedMinute = minute ?? 0
        guard (0...23).contains(resolvedHour), (0...59).contains(resolvedMinute) else {
            return makeDate(dayMonthYear, hour: 0, minute: 0, timeZone: labelTimeZone)
        }
        return makeDate(dayMonthYear, hour: resolvedHour, minute: resolvedMinute, timeZone: labelTimeZone)
    }

    static func parseCompactDayMonthYear(_ raw: String) -> Date? {
        guard let dayMonthYear = compactDayMonthYear(from: raw) else { return nil }
        return makeDate(dayMonthYear, hour: 0, minute: 0, timeZone: FrenchDateFormat.timeZone)
    }

    private static let labelTimeZone = FrenchDateFormat.timeZone

    private static func dayMonthYear(from raw: String) -> (day: Int, month: Int, year: Int)? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if let compact = compactDayMonthYear(from: trimmed) {
            return compact
        }
        let parts = trimmed
            .split { $0 == "/" || $0 == "-" }
            .map(String.init)
        guard parts.count == 3,
              let day = Int(parts[0]),
              let month = Int(parts[1]),
              let rawYear = Int(parts[2]),
              (1...31).contains(day),
              (1...12).contains(month) else {
            return nil
        }
        return (day, month, centuryAdjustedYear(rawYear))
    }

    private static func compactDayMonthYear(from raw: String) -> (day: Int, month: Int, year: Int)? {
        guard raw.count == 6, raw.allSatisfy(\.isNumber) else { return nil }
        guard let day = Int(raw.prefix(2)),
              let month = Int(raw.dropFirst(2).prefix(2)),
              let year2 = Int(raw.suffix(2)),
              (1...31).contains(day),
              (1...12).contains(month) else {
            return nil
        }
        return (day, month, centuryAdjustedYear(year2))
    }

    private static func centuryAdjustedYear(_ year: Int) -> Int {
        year < 100 ? 2000 + year : year
    }

    private static func makeDate(
        _ dayMonthYear: (day: Int, month: Int, year: Int),
        hour: Int,
        minute: Int,
        timeZone: TimeZone
    ) -> Date? {
        var components = DateComponents()
        components.calendar = Calendar(identifier: .gregorian)
        components.timeZone = timeZone
        components.year = dayMonthYear.year
        components.month = dayMonthYear.month
        components.day = dayMonthYear.day
        components.hour = hour
        components.minute = minute
        components.second = 0
        return components.date
    }
}
