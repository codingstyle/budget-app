import Foundation

enum FrenchDateFormat {
    static let timeZone = TimeZone(identifier: "Europe/Paris") ?? .gmt

    static var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = AppLocale.locale
        calendar.timeZone = timeZone
        return calendar
    }

    static func hasClockTime(_ date: Date) -> Bool {
        let parts = calendar.dateComponents([.hour, .minute], from: date)
        return (parts.hour ?? 0) != 0 || (parts.minute ?? 0) != 0
    }

    static func style(for date: Date) -> Date.VerbatimFormatStyle {
        if hasClockTime(date) {
            Date.VerbatimFormatStyle(
                format: "\(day: .twoDigits)/\(month: .twoDigits)/\(year: .padded(4)) \(hour: .twoDigits(clock: .twentyFourHour, hourCycle: .zeroBased)):\(minute: .twoDigits)",
                locale: AppLocale.locale,
                timeZone: timeZone,
                calendar: calendar
            )
        } else {
            Date.VerbatimFormatStyle(
                format: "\(day: .twoDigits)/\(month: .twoDigits)/\(year: .padded(4))",
                locale: AppLocale.locale,
                timeZone: timeZone,
                calendar: calendar
            )
        }
    }
}
