import Foundation

enum BNPParibasImporter {
    static func matches(_ grid: [Int: [Int: String]]) -> Bool {
        headerMap(in: grid) != nil
    }

    static func parse(data: Data) throws -> StatementPayload {
        let cells = try SpreadsheetLoader.firstSheetCells(from: data)
        return try parse(grid: XLSXWorkbook.grid(from: cells))
    }

    static func parse(grid: [Int: [Int: String]]) throws -> StatementPayload {
        let lastFour = extractLastFour(from: grid[1]?[1] ?? "")
        guard lastFour.count == 4 else {
            throw AppError.invalidSpreadsheet
        }
        guard let headers = headerMap(in: grid) else {
            throw AppError.invalidSpreadsheet
        }

        let balanceInfo = parseBalance(header: grid[1]?[2] ?? "", amount: grid[1]?[3] ?? "")
        let dateColumn = headers["dateoperation"] ?? 1
        let categoryColumn = headers["categorieoperation"] ?? 2
        let subcategoryColumn = headers["souscategorieoperation"] ?? 3
        let labelColumn = headers["libelleoperation"] ?? 4
        let amountColumn = headers["montantoperation"] ?? 5
        let pointingColumn = headers["pointageoperation"] ?? 6
        let commentColumn = headers["commentaireoperation"] ?? 7
        let headerRow = headers["_row"] ?? 3
        let maxRow = grid.keys.max() ?? headerRow
        var rows: [StatementOperationRow] = []
        for rowIndex in (headerRow + 1)...maxRow {
            guard let row = grid[rowIndex] else { continue }
            let label = row[labelColumn]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let amountRaw = row[amountColumn] ?? ""
            let dateRaw = row[dateColumn] ?? ""
            if label.isEmpty && amountRaw.isEmpty {
                continue
            }
            guard let effectDate = FrenchDateParsing.parse(dateRaw),
                  let amount = DecimalParsing.parse(amountRaw) else {
                continue
            }
            rows.append(
                StatementOperationRow(
                    effectDate: effectDate,
                    originalLabel: label,
                    amount: amount,
                    category: row[categoryColumn] ?? "",
                    subcategory: row[subcategoryColumn] ?? "",
                    pointing: row[pointingColumn] ?? "",
                    comment: row[commentColumn] ?? ""
                )
            )
        }

        return StatementPayload(
            bank: .bnpParibas,
            accountLastFour: lastFour,
            balanceDate: balanceInfo.date,
            balance: balanceInfo.amount,
            rows: rows
        )
    }

    private static func headerMap(in grid: [Int: [Int: String]]) -> [String: Int]? {
        let required = [
            "dateoperation",
            "categorieoperation",
            "souscategorieoperation",
            "libelleoperation",
            "montantoperation"
        ]
        for (index, row) in grid {
            var headers = SpreadsheetHeaders.normalized(row)
            let hasRequired = required.allSatisfy { headers[$0] != nil }
            guard hasRequired else { continue }
            headers["_row"] = index
            return headers
        }
        return nil
    }

    private static func extractLastFour(from text: String) -> String {
        let digits = text.filter(\.isNumber)
        return String(digits.suffix(4))
    }

    private static func parseBalance(header: String, amount: String) -> (date: Date?, amount: Decimal?) {
        let date = header.split(separator: " ").last.map(String.init).flatMap(FrenchDateParsing.parse)
        return (date, DecimalParsing.parse(amount))
    }
}
