import Foundation

enum SpreadsheetLoader {
    static func firstSheetCells(from data: Data) throws -> [SpreadsheetCell] {
        if CompoundFile.matches(data) {
            let workbook = try CompoundFile.stream(named: "Workbook", from: data)
            return try BIFFWorkbook.firstSheetCells(from: workbook)
        }
        if data.starts(with: [0x50, 0x4B, 0x03, 0x04]) {
            return try XLSXWorkbook.firstSheetCells(from: data)
        }
        throw AppError.importFailed("Format Excel non reconnu. Utilisez un export BNP au format .xls ou .xlsx.")
    }
}
