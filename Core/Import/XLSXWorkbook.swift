import Foundation

enum XLSXWorkbook {
    static func firstSheetCells(from data: Data) throws -> [SpreadsheetCell] {
        let sharedStringsData = (try? ZipArchive.data(named: "xl/sharedStrings.xml", in: data)) ?? Data()
        let sharedStrings = sharedStringsData.isEmpty ? [] : SharedStringsParser.parse(data: sharedStringsData)
        let sheetData = try ZipArchive.data(named: "xl/worksheets/sheet1.xml", in: data)
        return WorksheetParser.parse(data: sheetData, sharedStrings: sharedStrings)
    }

    static func grid(from cells: [SpreadsheetCell]) -> [Int: [Int: String]] {
        var grid: [Int: [Int: String]] = [:]
        for cell in cells {
            grid[cell.row, default: [:]][cell.column] = cell.value
        }
        return grid
    }
}
