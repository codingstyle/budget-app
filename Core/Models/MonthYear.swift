import Foundation

struct MonthYear: Hashable, Sendable {
    var month: Int
    var year: Int

    static var current: MonthYear {
        let components = AppLocale.calendar.dateComponents([.month, .year], from: .now)
        return MonthYear(month: components.month ?? 1, year: components.year ?? 2026)
    }

    var title: String {
        var components = DateComponents()
        components.month = month
        components.year = year
        let date = AppLocale.calendar.date(from: components) ?? .now
        return date.formatted(.dateTime.month(.wide).year().locale(AppLocale.locale))
    }

    func contains(_ date: Date, calendar: Calendar = AppLocale.calendar) -> Bool {
        let components = calendar.dateComponents([.month, .year], from: date)
        return components.month == month && components.year == year
    }

    var startDate: Date {
        var components = DateComponents()
        components.month = month
        components.year = year
        components.day = 1
        return AppLocale.calendar.date(from: components) ?? .now
    }

    var shortTitle: String {
        startDate.formatted(.dateTime.month(.abbreviated).year(.twoDigits).locale(AppLocale.locale))
    }

    func offset(byMonths delta: Int) -> MonthYear {
        let calendar = AppLocale.calendar
        let shifted = calendar.date(byAdding: .month, value: delta, to: startDate) ?? startDate
        let parts = calendar.dateComponents([.month, .year], from: shifted)
        return MonthYear(month: parts.month ?? month, year: parts.year ?? year)
    }

    var trailingTwelveMonths: [MonthYear] {
        (0..<12).map { offset(byMonths: $0 - 11) }
    }
}
