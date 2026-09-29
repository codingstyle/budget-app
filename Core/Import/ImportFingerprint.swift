import CryptoKit
import Foundation

enum ImportFingerprint {
    static func make(
        accountLastFour: String,
        effectDate: Date,
        amount: Decimal,
        originalLabel: String
    ) -> String {
        let parts = FrenchDateFormat.calendar.dateComponents([.year, .month, .day], from: effectDate)
        let year = parts.year ?? 0
        let month = parts.month ?? 0
        let day = parts.day ?? 0
        let monthText = month < 10 ? "0\(month)" : "\(month)"
        let dayText = day < 10 ? "0\(day)" : "\(day)"
        let date = "\(year)-\(monthText)-\(dayText)"
        let amountText = NSDecimalNumber(decimal: amount).stringValue
        let payload = "\(accountLastFour)|\(date)|\(amountText)|\(originalLabel)"
        let digest = SHA256.hash(data: Data(payload.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
