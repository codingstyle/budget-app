import Foundation

extension Decimal {
    var chartValue: Double {
        NSDecimalNumber(decimal: self).doubleValue
    }
}
