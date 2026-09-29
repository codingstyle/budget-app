import Foundation

enum AppLocale {
    static let identifier = "fr_FR"
    static let locale = Locale(identifier: identifier)

    static var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = locale
        calendar.timeZone = FrenchDateFormat.timeZone
        return calendar
    }
}
