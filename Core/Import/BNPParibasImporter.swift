import Foundation

enum BNPParibasImporter {
    static func load(from url: URL) throws -> BNPFilePayload {
        let data = try Data(contentsOf: url)
        return try parse(data: data)
    }

    static func parse(data: Data) throws -> BNPFilePayload {
        let cells = try SpreadsheetLoader.firstSheetCells(from: data)
        let grid = XLSXWorkbook.grid(from: cells)
        let lastFour = extractLastFour(from: grid[1]?[1] ?? "")
        guard lastFour.count == 4 else {
            throw AppError.invalidSpreadsheet
        }

        let balanceInfo = parseBalance(header: grid[1]?[2] ?? "", amount: grid[1]?[3] ?? "")
        let headers = normalizedHeaders(grid[3] ?? [:])
        try validateHeaders(headers)

        let dateColumn = headers["dateoperation"] ?? 1
        let categoryColumn = headers["categorieoperation"] ?? 2
        let subcategoryColumn = headers["souscategorieoperation"] ?? 3
        let labelColumn = headers["libelleoperation"] ?? 4
        let amountColumn = headers["montantoperation"] ?? 5
        let pointingColumn = headers["pointageoperation"] ?? 6
        let commentColumn = headers["commentaireoperation"] ?? 7

        let maxRow = grid.keys.max() ?? 3
        var rows: [BNPOperationRow] = []
        for rowIndex in 4...maxRow {
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
                BNPOperationRow(
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

        return BNPFilePayload(
            accountLastFour: lastFour,
            balanceDate: balanceInfo.date,
            balance: balanceInfo.amount,
            rows: rows
        )
    }

    private static func extractLastFour(from text: String) -> String {
        let digits = text.filter(\.isNumber)
        return String(digits.suffix(4))
    }

    private static func parseBalance(header: String, amount: String) -> (date: Date?, amount: Decimal?) {
        let date = header.split(separator: " ").last.map(String.init).flatMap(FrenchDateParsing.parse)
        return (date, DecimalParsing.parse(amount))
    }

    private static func normalizedHeaders(_ row: [Int: String]) -> [String: Int] {
        var result: [String: Int] = [:]
        for (column, title) in row {
            result[normalizeHeader(title)] = column
        }
        return result
    }

    private static func normalizeHeader(_ title: String) -> String {
        title
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "fr_FR"))
            .filter(\.isLetter)
            .lowercased()
    }

    private static func validateHeaders(_ headers: [String: Int]) throws {
        let required = [
            "dateoperation",
            "categorieoperation",
            "souscategorieoperation",
            "libelleoperation",
            "montantoperation",
            "pointageoperation",
            "commentaireoperation"
        ]
        for key in required where headers[key] == nil {
            throw AppError.invalidSpreadsheet
        }
    }
}
