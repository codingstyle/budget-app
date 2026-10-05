import Foundation

enum CreditAgricoleImporter {
    static func matches(_ grid: [Int: [Int: String]]) -> Bool {
        headerColumns(in: grid) != nil
    }

    static func parse(grid: [Int: [Int: String]]) throws -> StatementPayload {
        guard let header = headerColumns(in: grid) else {
            throw AppError.invalidSpreadsheet
        }
        let accountNumber = accountNumber(in: grid)
        let lastFour = String(accountNumber.filter(\.isNumber).suffix(4))
        guard lastFour.count == 4 else {
            throw AppError.invalidSpreadsheet
        }
        let balance = outstanding(in: grid)
        let maxRow = grid.keys.max() ?? header.row
        var rows: [StatementOperationRow] = []
        for rowIndex in (header.row + 1)...maxRow {
            guard let row = grid[rowIndex] else { continue }
            let label = row[header.label]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let debitRaw = row[header.debit] ?? ""
            let creditRaw = row[header.credit] ?? ""
            if label.isEmpty && debitRaw.isEmpty && creditRaw.isEmpty {
                continue
            }
            guard let effectDate = FrenchDateParsing.parse(row[header.date] ?? "") else {
                continue
            }
            guard let amount = signedAmount(debit: debitRaw, credit: creditRaw) else {
                continue
            }
            rows.append(
                StatementOperationRow(
                    effectDate: effectDate,
                    valueDate: FrenchDateParsing.parse(row[header.valueDate] ?? ""),
                    originalLabel: label,
                    amount: amount
                )
            )
        }

        return StatementPayload(
            bank: .creditAgricole,
            accountLastFour: lastFour,
            accountNumber: accountNumber,
            balanceDate: balance.date,
            balance: balance.amount,
            rows: rows
        )
    }

    private static func headerColumns(in grid: [Int: [Int: String]]) -> (
        row: Int,
        date: Int,
        valueDate: Int,
        label: Int,
        debit: Int,
        credit: Int
    )? {
        for (index, row) in grid {
            let headers = SpreadsheetHeaders.normalized(row)
            guard let date = headers["date"],
                  let label = headers["libelle"],
                  let debit = headers["debiteuros"] ?? headers["debit"],
                  let credit = headers["crediteuros"] ?? headers["credit"] else {
                continue
            }
            return (
                row: index,
                date: date,
                valueDate: headers["datevaleur"] ?? date,
                label: label,
                debit: debit,
                credit: credit
            )
        }
        return nil
    }

    private static func accountNumber(in grid: [Int: [Int: String]]) -> String {
        for row in grid.values {
            for value in row.values {
                let normalized = SpreadsheetHeaders.normalize(value)
                guard normalized.contains("comptededepot") else { continue }
                let digits = value.filter(\.isNumber)
                if digits.count >= 4 {
                    return digits
                }
            }
        }
        return ""
    }

    private static func outstanding(in grid: [Int: [Int: String]]) -> (date: Date?, amount: Decimal?) {
        for row in grid.values {
            guard let soldeCell = row.values.first(where: { SpreadsheetHeaders.normalize($0).hasPrefix("soldeau") }) else {
                continue
            }
            let dateToken = soldeCell.split(separator: " ").last.map(String.init) ?? soldeCell
            return (FrenchDateParsing.parse(dateToken), row.values.compactMap(DecimalParsing.parse).first)
        }
        return (nil, nil)
    }

    private static func signedAmount(debit: String, credit: String) -> Decimal? {
        if let debitAmount = DecimalParsing.parse(debit) {
            return debitAmount == 0 ? DecimalParsing.parse(credit) : -abs(debitAmount)
        }
        if let creditAmount = DecimalParsing.parse(credit) {
            return abs(creditAmount)
        }
        return nil
    }
}
