import Foundation

enum BIFFWorkbook {
    private static let numberRecord: UInt16 = 0x0203
    private static let labelRecord: UInt16 = 0x0204
    private static let rkRecord: UInt16 = 0x027E
    private static let labelSSTRecord: UInt16 = 0x00FD
    private static let sstRecord: UInt16 = 0x00FC
    private static let continueRecord: UInt16 = 0x003C

    static func firstSheetCells(from workbook: Data) throws -> [SpreadsheetCell] {
        var offset = 0
        var cells: [SpreadsheetCell] = []
        var sst: [String] = []

        while offset + 4 <= workbook.count {
            let type = workbook.uInt16(at: offset)
            let length = Int(workbook.uInt16(at: offset + 2))
            let next = offset + 4 + length
            guard next <= workbook.count else { break }
            let payload = workbook.subdata(in: (offset + 4)..<next)
            offset = next

            switch type {
            case sstRecord:
                var sstData = payload
                while offset + 4 <= workbook.count, workbook.uInt16(at: offset) == continueRecord {
                    let continueLength = Int(workbook.uInt16(at: offset + 2))
                    let continueNext = offset + 4 + continueLength
                    guard continueNext <= workbook.count else { break }
                    sstData.append(workbook.subdata(in: (offset + 4)..<continueNext))
                    offset = continueNext
                }
                sst = parseSST(sstData)
            case labelRecord:
                if let cell = parseLabel(payload) {
                    cells.append(cell)
                }
            case numberRecord:
                if let cell = parseNumber(payload) {
                    cells.append(cell)
                }
            case rkRecord:
                if let cell = parseRK(payload) {
                    cells.append(cell)
                }
            case labelSSTRecord:
                if let cell = parseLabelSST(payload, sst: sst) {
                    cells.append(cell)
                }
            default:
                break
            }
        }

        if cells.isEmpty {
            throw AppError.invalidSpreadsheet
        }
        return cells
    }

    private static func parseLabel(_ payload: Data) -> SpreadsheetCell? {
        guard payload.count >= 8 else { return nil }
        let row = Int(payload.uInt16(at: 0)) + 1
        let column = Int(payload.uInt16(at: 2)) + 1
        let characterCount = Int(payload.uInt16(at: 6))
        let remainder = payload.subdata(in: 8..<payload.count)
        let text = consumeExcelString(remainder, characterCount: characterCount).text
        return SpreadsheetCell(row: row, column: column, value: text)
    }

    private static func parseNumber(_ payload: Data) -> SpreadsheetCell? {
        guard payload.count >= 14 else { return nil }
        let row = Int(payload.uInt16(at: 0)) + 1
        let column = Int(payload.uInt16(at: 2)) + 1
        let value = payload.double(at: 6)
        return SpreadsheetCell(row: row, column: column, value: string(from: value))
    }

    private static func parseRK(_ payload: Data) -> SpreadsheetCell? {
        guard payload.count >= 10 else { return nil }
        let row = Int(payload.uInt16(at: 0)) + 1
        let column = Int(payload.uInt16(at: 2)) + 1
        let rk = payload.int32(at: 6)
        return SpreadsheetCell(row: row, column: column, value: string(from: double(fromRK: rk)))
    }

    private static func parseLabelSST(_ payload: Data, sst: [String]) -> SpreadsheetCell? {
        guard payload.count >= 10 else { return nil }
        let row = Int(payload.uInt16(at: 0)) + 1
        let column = Int(payload.uInt16(at: 2)) + 1
        let index = Int(payload.uInt32(at: 6))
        guard sst.indices.contains(index) else { return nil }
        return SpreadsheetCell(row: row, column: column, value: sst[index])
    }

    private static func parseSST(_ data: Data) -> [String] {
        guard data.count >= 8 else { return [] }
        let uniqueCount = Int(data.uInt32(at: 4))
        var offset = 8
        var strings: [String] = []
        while strings.count < uniqueCount, offset < data.count {
            guard offset + 3 <= data.count else { break }
            let characterCount = Int(data.uInt16(at: offset))
            offset += 2
            let parsed = consumeExcelString(data.subdata(in: offset..<data.count), characterCount: characterCount)
            strings.append(parsed.text)
            offset += parsed.consumed
        }
        return strings
    }

    private static func consumeExcelString(_ data: Data, characterCount: Int) -> (text: String, consumed: Int) {
        guard data.isEmpty == false else { return ("", 0) }
        let flags = data[0]
        let isUTF16 = (flags & 0x01) != 0
        var offset = 1
        var richCount = 0
        var asianSize = 0
        if flags & 0x08 != 0, offset + 2 <= data.count {
            richCount = Int(data.uInt16(at: offset))
            offset += 2
        }
        if flags & 0x04 != 0, offset + 4 <= data.count {
            asianSize = Int(data.uInt32(at: offset))
            offset += 4
        }

        let byteCount = isUTF16 ? characterCount * 2 : characterCount
        let end = min(data.count, offset + byteCount)
        let textData = data.subdata(in: offset..<end)
        let text: String
        if isUTF16 {
            text = String(data: textData, encoding: .utf16LittleEndian) ?? ""
        } else {
            text = String(data: textData, encoding: .isoLatin1) ?? ""
        }
        let consumed = end + richCount * 4 + asianSize
        return (text, consumed)
    }

    private static func double(fromRK rk: Int32) -> Double {
        var value: Double
        if rk & 0x02 != 0 {
            value = Double(rk >> 2)
        } else {
            let shifted = UInt64(UInt32(bitPattern: rk) & 0xFFFFFFFC) << 32
            value = Double(bitPattern: shifted)
        }
        if rk & 0x01 != 0 {
            value /= 100
        }
        return value
    }

    private static func string(from value: Double) -> String {
        if value.isNaN || value.isInfinite {
            return ""
        }
        let number = NSDecimalNumber(value: value)
        let behavior = NSDecimalNumberHandler(
            roundingMode: .plain,
            scale: 10,
            raiseOnExactness: false,
            raiseOnOverflow: false,
            raiseOnUnderflow: false,
            raiseOnDivideByZero: false
        )
        return number.rounding(accordingToBehavior: behavior).stringValue
    }
}
