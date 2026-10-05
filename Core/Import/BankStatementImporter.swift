import Foundation

enum BankStatementImporter {
    static func parse(data: Data) throws -> StatementPayload {
        let cells = try SpreadsheetLoader.firstSheetCells(from: data)
        let grid = XLSXWorkbook.grid(from: cells)
        if CreditAgricoleImporter.matches(grid) {
            return try CreditAgricoleImporter.parse(grid: grid)
        }
        if BNPParibasImporter.matches(grid) {
            return try BNPParibasImporter.parse(grid: grid)
        }
        throw AppError.invalidSpreadsheet
    }
}
