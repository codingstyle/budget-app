import Foundation

final class WorksheetParser: NSObject, XMLParserDelegate {
    private let sharedStrings: [String]
    private var cells: [SpreadsheetCell] = []
    private var currentReference: String?
    private var currentType: String?
    private var currentValue = ""
    private var isValue = false
    private var isInlineText = false

    init(sharedStrings: [String]) {
        self.sharedStrings = sharedStrings
    }

    static func parse(data: Data, sharedStrings: [String]) -> [SpreadsheetCell] {
        let parser = WorksheetParser(sharedStrings: sharedStrings)
        let xml = XMLParser(data: data)
        xml.delegate = parser
        xml.parse()
        return parser.cells
    }

    func parser(
        _ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?,
        attributes attributeDict: [String: String] = [:]
    ) {
        switch elementName {
        case "c":
            currentReference = attributeDict["r"]
            currentType = attributeDict["t"]
            currentValue = ""
        case "v":
            isValue = true
            currentValue = ""
        case "t":
            isInlineText = currentType == "inlineStr"
            if isInlineText {
                currentValue = ""
            }
        default:
            break
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if isValue || isInlineText {
            currentValue += string
        }
    }

    func parser(
        _ parser: XMLParser,
        didEndElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?
    ) {
        switch elementName {
        case "v":
            isValue = false
        case "t":
            isInlineText = false
        case "c":
            appendCurrentCell()
            currentReference = nil
            currentType = nil
            currentValue = ""
        default:
            break
        }
    }

    private func appendCurrentCell() {
        guard let reference = currentReference,
              let column = ColumnReference.index(from: reference),
              let row = ColumnReference.row(from: reference) else { return }

        let resolved: String
        if currentType == "s", let index = Int(currentValue), sharedStrings.indices.contains(index) {
            resolved = sharedStrings[index]
        } else {
            resolved = currentValue
        }

        cells.append(SpreadsheetCell(row: row, column: column, value: resolved))
    }
}
